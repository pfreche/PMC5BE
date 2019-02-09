class Fit < ApplicationRecord
	belongs_to :bookmark,  optional: true
	has_many :tworkers

def matches?(url)
    regex = %r{#{pattern}}
    result = regex.match(url)
 end

 def self.findFits(url)

	fits = Fit.all.to_a
	fits.select! {|f| 
		regex = %r{#{f.pattern}} 
        regex.match(url)
    }
   fits
end

def matchingBookmarks
    bookmarks = Bookmark.all.to_a
    regex = %r{#{pattern}} 
    bookmarks.select! { |b|
        regex.match(b.url)	
    } 
    bookmarks
end

def self.scanUrl(url)
   result = []
   fits = Fit.findFits(url)
   fits.each { |fit|
   	   tworkers = fit.tworkers
   	   tworkers.each { |tworker|
         result = tworker.scanUrl(url)
   	   }
   }
   result
end

  def self.matchAndScan(url, maxdepth=5, level = 0, result={})

    maxdepth = maxdepth - 1
    return {} if maxdepth < 0

    fits = Fit.findFits(url)
    fits.each { |fit|
       result[fit.pattern] = {level: level, action: 0, fit_id: fit.id}
  	   tworkers = fit.tworkers
   	   tworkers.each { |tworker|
          if tworker.action == 10 # youtube ?? > no url scan
            result[url] = [level,tworker.action]
          else 
            thislinks = tworker.scanUrl(url).uniq # uniq added 20171014
            if maxdepth == 0 and level == 1
             if thislinks.length == 1
       #          adfe
             end
            end
            thislinks.each {|l|
               unless result[l] && result[l][:scanned]      # if link is not already found 

                  result[l] = {level: level, action: tworker.action, tworker_id: tworker.id, scanned: false}
                  unless tworker.final 
                    u =  Fit.matchAndScan(l, maxdepth, level + 1,result)
                  end
      	       end
       	    }
          end
        }
    } 
    rt = result[url]
    if rt 
        result[url] = {level: rt[:level], 
    			   action: rt[:action], 
    			   tworker_id: rt[:tworker_id],
    				scanned: true}
    end
    result 
 end

def self.detCommonStart(links)

   cs = nil
   x = 0
   links.each {|link, value| 
      next unless value[:action] == 1 # take only finals
      l = link.strip          # the url
      x = x + 1
      if !cs
        cs = l
      else
        len = l.length
        len = cs.length if len>cs.length
        j = -1
        (0...len).each { |i|
          break if cs[i] != l[i]
          j = j + 1
        }
        cs = l[0..j]
      end
   }

   return "" unless cs
  /(.*\/)/.match(cs)[1].strip
end


  def self.locations(start) 
    possibleLocations = Location.all.select{|l| start.include? l.uri} # besser auf der DB ???
  end
 
  def self.scanAndCreateFolderAndMfiles(url,location_id)

    result = Fit.matchAndScan(url)
    title = ""
    url_parent_bookmark = nil
    url_parent_bookmark_title = nil
    
    result.each do |f,g| 
    	if (g[:action] ==3)
    	  title = f
    	end
    	if (g[:action] ==4)
    	  url_parent_bookmark = f
          url_parent_bookmark_title = f      
    	end
    end 
    parent_bookmark_id = nil
    if url_parent_bookmark 
       parent_bookmark_id = Bookmark.newOnly({url: url_parent_bookmark, 
       	                          title: url_parent_bookmark_title}).id
    end

    bookmark = Bookmark.newOnly({url: url, 
    	title: title, bookmark_id: parent_bookmark_id})

    location = Location.find(location_id)
    commonStart = Fit.detCommonStart(result)
    folder = Folder.createFrom(commonStart,bookmark,location) 
    mfiles = Mfile.createFrom(result, folder,location)
    folder
  end

end

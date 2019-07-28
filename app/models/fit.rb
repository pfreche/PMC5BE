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

   def self.matchAndScantText(text)
     result = []
     fits = Fit.findFits(text)
     fits.each do |fit|
        tworkers = fit.tworkers
        tworkers.each do |tworker|
          if !tworker.tag || tworker.tag == "" 
              element = tworker.buildOutcome([text,""]);
              if element
                 result << {element: element, action: tworker.action, prop_config: tworker.prop_config }
              end  
          end
        end
     end
     result
   end

   def self.transformBookmark(bookmark)
     result = Fit.matchAndScantText(bookmark.url)
     result.each do |f| 
    	if (f[:action] == 7) # replace url
        bookmark.url = f[:element]
        bookmark.save
    	end
    end
   end

  def self.matchAndScan(url, maxdepth=3, level = 0, result={}, result2=[], scannedUrl={})

    maxdepth = maxdepth - 1
    return {} if maxdepth < 0
 
    return result if scannedUrl[url];  # avoid double scans 
    scannedUrl[url]=true

    fits = Fit.findFits(url)
    fits.each { |fit|
       result2 << {typ: "fit", level: level, link: url, pattern: fit.pattern, fit_id: fit.id }
       result[fit.pattern] = {level: level, action: 0, fit_id: fit.id}
  	   tworkers = fit.tworkers
   	   tworkers.each { |tworker|
          if tworker.action == 10 # youtube ?? > no url scan
            result[url] = [level,tworker.action]
          else 
            foundElmenents = tworker.scanUrl(url)
#            if !tworker.final
#              foundElmenents = foundElmenents.uniq # when further scanning needed avoid double urls
#            end
            foundElmenents.each {|element|
              if scannedUrl[element]  # element bereits gescannt.
              else
                  result2 << {typ: "tworker", level: level, link: element, pattern: tworker.pattern, action: tworker.action, tag_attr: (tworker.tag||"" + "|" + tworker.attr||"" ), prop_config: tworker.prop_config ,scanned: false}
                  result[element] = {level: level, action: tworker.action, tworker_id: tworker.id, scanned: false}
                  unless tworker.final # then it is an URL
                     Fit.matchAndScan(element, maxdepth, level + 1,result, result2)
                   end
              end
       	    }
          end
        }
    } 
#    rt = result[url]
#    if rt 
#        result[url] = {level: rt[:level], 
#    			   action: rt[:action], 
#    			   tworker_id: rt[:tworker_id],
#    				scanned: true}
#    end
    [result, result2] 
 end

def self.detCommonStart(foundElements)

   cs = nil
   x = 0
   foundElements.each {|element| 
      next unless element[:action] == 1 || element[:action] == 8 # only save and youtube
      l = element[:link]          # the url
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

    result = Fit.matchAndScan(url)[1]
    title = ""
    url_parent_bookmark = nil
    url_parent_bookmark_title = nil
    folderAttris = []

    result.each do |f| 
    	if (f[:action] ==3)
    	  title = f[:link]
    	end
    	if (f[:action] ==4)
    	  url_parent_bookmark = f[:link]
          url_parent_bookmark_title = f[:link]      
    	end
    	if (f[:action] ==6)
    	  folderAttris << f[:link]
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
    folder.addAttris(folderAttris);
    self.createMfiles(folder, result)
    folder
  end

  def self.scanAndCreateMfiles(folder)
    bookmark = folder.bookmark
    typ = folder.storage.originTyp

    if typ == 1 # then it is from the web
      result = Fit.matchAndScan(bookmark.url)[1]
      self.createMfiles(folder, result)
    end
    if typ == 2 # then it is from the filesystem
       folder.storage.originLocation.scanMfiles(folder,"")
    end
    folder
  end

  def self.createMfiles(folder, result)
    location = folder.storage.originLocation
    Mfile.cutFilenames(result,folder,location)
    mfiles = Mfile.createFrom(result, folder,location)
    if (result.count {|r| r[:action] == 8}) > 0 # youtube link there
      folder.createYoutubeDownloader(folder.bookmark.url);
      folder.storage.location(2).scanMfiles(folder, "jpg")
    end
  end

end

class Tworker < ApplicationRecord
	belongs_to :fit

 def scanUrl(url)
    text = FileHandler.loadUrl(url)
    scan(text,url)
 end

 def scan(text,urlbase)

    if tag.strip == ""
      links = []
      links[0] = text
    else 
      page = Nokogiri::HTML(text)
      links = page.css(tag)
  
      i = 0
      links = links.map { |l| 
        begin
          if attr and attr.length >0 
            URI.decode(URI.join(urlbase, URI.encode((l.attr(attr)||"").to_s)).to_s)
          else 
            i = i  + 1
            l.text.to_s
          end
        rescue
          "failure"
        end
      }
    end
    pa = pattern
#    pattern = pa.sub("<url>",url)

    links.select! { |l| l[%r{#{pattern}}] } if pattern

    if pattern and pattern.length >0 
        links.map! { |link| 
          %r{#{pattern}}.match(link)[1]
        } 
    end

    links

 end


  def self.matchAndScan(url, maxdepth=3, level = 0, scanners=nil, result={})

    maxdepth = maxdepth - 1
    return {} if maxdepth < 0
    tworkers ||= Tworker.all
    tworkers.each {|tworker|
       if tworker.fit.matches?(url)
          if tworker.action == 10 # youtube ?? > no url scan
            result[url] = [level,tworker.action]
          end
            thislinks = tworker.scanUrl(url).uniq # uniq added 20171014
            thislinks.each {|l|
               unless result[l]          # if link is not already found 
                  result[l] = [level, tworker.action]
                  unless tworker.final 
                    u =  Tworker.matchAndScan(l, level + 1, maxdepth, scanners, result)
                  end
      	       end
       	    }
       end
    } 
    result 
 end

end

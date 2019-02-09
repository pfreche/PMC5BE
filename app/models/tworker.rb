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
            a = URI.decode(URI.join(urlbase, URI.encode((l.attr(attr)||"").to_s)).to_s)
          else 
          	a = ""
          end
          i = i  + 1
          content =  l.text.to_s
          [a,content]
        rescue
           ["fail", "ure"]
        end
      }
    end
    pa = pattern
#    pattern = pa.sub("<url>",url)
    if pattern 
      links.select! { |link| 
      	m = (link[0] == "") ? 1:0
      	link[m][%r{#{pattern}}] 
      	} 
    end
    if pattern and pattern.length >0 
        links.map! { |link| 
 		   	m = (link[0] == "") ? 1:0
 		   	matche = %r{#{pattern}}.match(link[m])
         	result =  matche[1]
          if formular and formular.length > 0
               result = formular.sub("<result>",result)
               result = result.sub("<r2>", matche[2]) if matche[2]
               result = result.sub("<content>", link[1])
               
          end
          result
        } 
    else
       links.map! { |link| link[1] }
    end

    links

 end


  def self.matchAndScan_disabled(url, maxdepth=3, level = 0, scanners=nil, result={})

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

 class Bookmark < ActiveRecord::Base
  belongs_to :folder, optional: true # connection to downloaded folder
  belongs_to :mfile   # connection to mfile from type bookmark to enable classifications
#  has_one :fit  

def getTitle(saveIt = false, changeIfUnavailable = false)

  titleNew = "keeee"
  begin
    text = FileHandler.loadUrl(URI.escape(url))
    page = Nokogiri::HTML(text)
    titleNew = page.css("title")[0].text
    available = true
  rescue StandardError
    titleNew = "site not available: " 
    available = false
  end
  if saveIt 
    if available || changeIfUnavailable
      self.title = titleNew
      self.save
    end
  end
  titleNew 
end

def folderTitle
   if folder
   	folder.title
   else
   	"not available"
   end
end

def create_mfile
     
     if not mfile_id || mfile_id == 0
       mfile = Mfile.new
       mfile.mtype = Mfile::MFILE_BOOKMARK
       mfile.filename = ""
       mfile.modified = Time.now
       mfile.mod_date = Time.now
       mfile.save
       self.mfile =  mfile
#       mfile_id = mfile.id
     end # das ganze funktioniert nicht!!!! mfile_id bleibt of nil
end

def save
  create_mfile
  puts mfile_id
    super
end

def updateFolderTitle
    if folder_id
      folder.update(title: title)
    end
end

def self.newOnly(h)
     b = Bookmark.find_by_url(h[:url])
     if not b
       b = Bookmark.new(url: h[:url], title: h[:title], bookmark_id: h[:bookmark_id])
       b.save
     else
       if b.bookmark_id != h[:bookmark_id]
          b.bookmark_id = h[:bookmark_id]
          b.save
       end
     end
     b
end

def self.domains()
	pattern = "(https?:\/\/[a-zA-Z0-9\-\._]+).*"
#    pattern = "(.*)"
   Bookmark.all.map { |bm| 
      a = %r{#{pattern}}.match(bm.url)
      if a 
      	a[1]
      else
      	"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"+bm.url
      end
   }.uniq
end

def self.findByDomain(domain)
    Bookmark.where("url like '#{domain}%'")
end


end

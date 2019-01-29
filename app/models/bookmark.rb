class Bookmark < ActiveRecord::Base
  belongs_to :folder, optional: true # connection to downloaded folder
  belongs_to :mfile   # connection to mfile from type bookmark to enable classifications
#  has_one :fit  



def folderTitle
   if folder
   	folder.title
   else
   	"not available"
   end
end

def create_mfile
     
     if not mfile_id
       mfile = Mfile.new
       mfile.mtype = Mfile::MFILE_BOOKMARK
       mfile.filename = ""
       mfile.modified = Time.now
       mfile.mod_date = Time.now
       mfile.save
       self.mfile =  mfile
#       mfile_id = mfile.id
     end 
end

def save
	create_mfile
    super
end

def self.newOnly(h)
     b = Bookmark.find_by_url(h[:url])
     if not b
       b = Bookmark.new(url: h[:url], title: h[:title])
       b.save
     end
     b
end

end

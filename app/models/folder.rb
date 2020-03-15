class Folder < ActiveRecord::Base
  belongs_to :storage
  has_many :mfiles,  :dependent => :destroy
  has_one :bookmark
  
  def downloadable 
    storage.downloadable
  end

  def orginalWebLocation
    storage.orginalWebLocation
  end

  def fsInuse
  	storage.orginalWebLocation
  end


  def originPath
        ppath = storage.originPath ||  "<not defined>"
        File.join(ppath,mpath,lfolder) 
  end


  def path(typ)    
        ppath = storage.path(typ)
        File.join(ppath,mpath,lfolder)  ||  "<not defined>"
  end

  def dir(relpath)
  	  FileHandler.dir(File.join(path(2),relpath))
  end

  def scan(relpath, filter = nil)
      FileHandler.scan(File.join(path(2),relpath), filter)
  end

def scanAndAdd (filter = nil)

    files = scan("",filter)
    files.each { |file|

       filename = ""
       last = file.pop
       file.each { |f|  filename = filename + file[i]
           filename = filename + "/"
       }
       filename = last
       Mfile.find_or_create_by(folder_id: folder.id, 
                                  filename: filename) do |mfile|
              mfile.mtype = Mfile::MFILE_UNDEFINED 
       end
      }
   files
end




  def self.createFrom(commonStart,bookmark,location) 

      locationLength = location.uri.length
      ldiff = - commonStart.length + locationLength 
      if ldiff < 0 
         foldername = commonStart[ldiff..-1]   
      else
         foldername = ""
      end 

      folder = Folder.find_or_create_by(id: bookmark.folder_id) do |folder|
           folder.title = bookmark.title
           folder.storage_id =  location.storage_id
           folder.lfolder =  ""
           folder.mpath = foldername
           folder.id = nil
        end
     if folder.id == 0
adfe
     end


        if  bookmark.folder_id !=  folder.id
           bookmark.folder_id = folder.id
           bookmark.save
        end

      folder
  end

end

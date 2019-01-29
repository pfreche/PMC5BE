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

  def self.createFrom(commonStart,bookmark,location) 

      locationLength = location.uri.length
      ldiff = - commonStart.length + locationLength 
      if ldiff < 0 
         foldername = commonStart[ldiff..-1]   
      else
         foldername = ""
      end 

      if bookmark.folder_id 
         begin 
           folder = Folder.find(bookmark.folder_id)
         rescue
         end
      end   
      if  not folder
         folder = Folder.new(title: bookmark.title, 
                          storage_id: location.storage_id,
                          lfolder: "",
                          mpath: foldername)
        folder.save
        bookmark.folder_id = folder.id
        bookmark.save
      end
      folder
  end

end

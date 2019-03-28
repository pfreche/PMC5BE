class Location < ActiveRecord::Base

  belongs_to :storage
  def dir(relpath)
        list =  FileHandler.dir(File.join(uri,relpath))
        list.map do |el|
            state = 0 
            mpath = File.join(relpath, el[:file])+"/"
            if el[:isDir]
                folder = Folder.find_by(storage_id: storage_id,mpath: mpath)
                state = folder ? 2 : 1
            end 
           {file: el[:file],isDir: el[:isDir], state: state } 
        end
  end

  def addFolder(relpath)
    mpath = (relpath[-1] == "/") ? relpath : relpath+"/"
    folder = Folder.find_by(storage_id: storage_id,mpath: mpath)
    unless folder 
        folder = Folder.create do |folder|
            folder.title = "from FS"
            folder.storage_id =  storage_id
            folder.lfolder =  ""
            folder.mpath = mpath
         end
    end
    folder
  end

  def scanMfiles(folder, filter)
    files = FileHandler.dirDeep(File.join(uri, folder.mpath),filter)
    files.each do |file|
       mfile = Mfile.find_or_create_by(folder_id: folder.id, filename: file) do |m|
         m.folder_id = folder.id
         m.filename = file
       end
   
    end
    files
  end

end

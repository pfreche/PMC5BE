class Location < ActiveRecord::Base

  belongs_to :storage

  def dir(relpath)
        list =  FileHandler.dir(File.join(uri,relpath))
        list.map do |el|
            state = 0 
            mpath = File.join(relpath, el[:file])+"/"
            if el[:isDir]
              if el[:file] == ".."
                {file: el[:file],isDir: el[:isDir], state: -1} 
              else
                folder = Folder.find_by(storage_id: storage_id,mpath: mpath)
                if folder
                  {file: el[:file],isDir: el[:isDir], state: 2, folder_id: folder.id, title: folder.title} 
                else
                  {file: el[:file],isDir: el[:isDir], state: 1} 
                end
              end
              else
                {file: el[:file],isDir: el[:isDir], state: 0} 
            end 
        end
  end

  def addFolder(relpath)
    mpath = (relpath[-1] == "/") ? relpath : relpath+"/"
    folder = Folder.find_by(storage_id: storage_id,mpath: mpath)
    unless folder 
        folder = Folder.create do |folder|
            folder.title = relpath.split("/")[-1]
            folder.storage_id =  storage_id
            folder.lfolder =  ""
            folder.mpath = mpath
         end
    end
    folder
  end

  def scanMfiles(folder, filter)
    files = FileHandler.dirDeep(File.join(uri, folder.mpath),filter)
    result = []
    fit = Fit.find(storage.fit_id)
    files.each do |file|
      
      # get Fit from storage
       if fit && fit.matches?(file)
#        entry = {}
#        entry[:filename] = file
#        entry[:action] = 1
#        result << entry
        fit.tworkers.each { |tworker|
           outcome = tworker.buildOutcome(file)
           if outcome
             entry = {}
             entry[:action] = tworker.action
             entry[:prop_config] = tworker.prop_config
             entry[:filename]  = outcome
             entry[:link]  = outcome
             result << entry
            end
         } 
       end
     end
   
#    files.each do |file|
#       mfile = Mfile.find_or_create_by(folder_id: folder.id, filename: file) do |m|
#         m.folder_id = folder.id
#         m.filename = file
#         m.mtype = mtype
#       end 
#    end
     Mfile.createFrom(result,folder,self)
     files    
  end

end

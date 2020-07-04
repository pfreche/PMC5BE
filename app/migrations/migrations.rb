class Migrations

  MFILE_UNDEFINED = 0
  MFILE_LOCATION = 1
  MFILE_PHOTO = 2 # Fotos und Videos selbst gedreht
  MFILE_MOVIE = 3 # Filme aus Kino und Fernsehen
  MFILE_BOOK = 4 # Ebooks
  MFILE_IMEDIUM = 5
  MFILE_BOOKMARK = 6 # Bookmarks
  MFILE_YOUTUBE = 7 # Youtube
  MFILE_FOLDER = 8 # Folder

  def migrateFolders(storage_id, gtype)
    folders = Storage.find(storage_id).folders
    folders.each do |folder|
      group = Group.find_or_create_by({
                                          id: folder.id,
                                          name: folder.title,
                                          path: getPath(folder),
                                          gtype: gtype,
                                          medium_id: folder.mfile_id,
                                          storage_id: folder.storage_id
                                      })
      if folder.mfile_id != nil
        Medium.find_or_create_by({
                                     id: folder.mfile_id,
                                     name: folder.title,
                                     mtype: 8,
                                     group_id: nil # erstmal keine Rückwärtsverknüfung
                                 })
        MeFile.find_or_create_by({
                                     medium_id: folder.mfile_id,
                                     name: nil,
                                     path: getPath(folder),
                                     ftype: 0, # folder
                                     storage_id: storage_id
                                 })
      end
    end
  end

  def migrateFiles(storage_id)
    folders = Storage.find(storage_id).folders
    folders.each do |folder|
      fpath = getPath(folder)
      mfiles = folder.mfiles
      mfiles.each do |mfile|
        if mfile.mtype == 5
          Medium.find_or_create_by({
                                       id: mfile.id,
                                       name: mfile.filename,
                                       mtype: mfile.mtype,
                                       group_id: folder.id,
                                       modified: mfile.modified,
                                       mod_date: mfile.mod_date
                                   })

#        if (mfile.filename == nil ||mfile.filename.empty?)
          name = extractFilename(mfile.filename)
          path = extractPath(fpath + mfile.filename)
          MeFile.find_or_create_by({
                                       medium_id: mfile.id,
                                       name: name,
                                       path: path,
                                       ftype: 1, # primary
                                       storage_id: storage_id
                                   })

          MeFile.find_or_create_by({
                                       medium_id: mfile.id,
                                       name: name.gsub!(/\.[\w]*$/, ".jpg"), # Assuming Thumbnails currently have always jpg's,
                                       path: path,
                                       ftype: 2, # TN
                                       storage_id: storage_id
                                   })

        end
      end
    end
  end

  def migrateBookmarks()
    bookmarks = Bookmark.all
    bookmarks.each do |bookmark|
      Bookmark.find_or_create_by({
                                   id: folder.mfile_id,
                                   name: folder.title,
                                   mtype: 8,
                                   group_id: nil # erstmal keine Rückwärtsverknüfung
                               })


    end
  end

  def getPath(folder)
    if folder.lfolder == nil or folder.lfolder.empty?
      path = folder.mpath
    else
      path = folder.mpath +"/" + folder.lfolder
    end
  end

  def extractFilename(name)
    name.gsub(/\?.*/, "").gsub(/.*\//, "")
  end

  def extractPath(name)
    name.gsub(/\/[^\/]*$/, "") + "/"
  end
end


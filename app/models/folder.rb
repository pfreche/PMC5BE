class Folder < ActiveRecord::Base
  belongs_to :storage
  has_many :mfiles, :dependent => :destroy
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
    ppath = storage.originPath || "<not defined>"
    File.join(ppath, mpath, lfolder)
  end


  def path(typ)
    ppath = storage.path(typ)
    File.join(ppath, mpath, lfolder) || "<not defined>"
  end

  def dir(relpath)
    FileHandler.dir(File.join(path(2), relpath))
  end

  def scan(relpath, filter = nil)
    FileHandler.scan(File.join(path(2), relpath), filter)
  end

  def scanAndAdd (filter = nil)

    files = scan("", filter)
    files.each { |file|

      filename = ""
      last = file.pop
      file.each { |f| filename = filename + file[i]
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

  def deletePhysicalFilesFromFS
    mfiles.each { |mfile| mfile.deleteFromFS }
  end

  def removeMfilesWOPhysicalFiles
    mfiles.each do |mfile|
      if mfile.mtype != Mfile::MFILE_FOLDER && !mfile.fileExistonFS?
        mfile.delete
      end
    end
  end


  def deleteFromFS
#    FileHandler.deleteDirectory(path(Mfile::URL_STORAGE_FS));
  end

  def self.createFrom(commonStart, bookmark, location)

    locationLength = location.uri.length
    ldiff = -commonStart.length + locationLength
    if ldiff < 0
      foldername = commonStart[ldiff..-1]
    else
      foldername = ""
    end

    folder = Folder.find_or_create_by(id: bookmark.folder_id) do |folder|
      folder.title = bookmark.title
      folder.storage_id = location.storage_id
      folder.lfolder = ""
      folder.mpath = foldername
      folder.id = nil
    end
    if folder.id == 0
      adfe
    end

    if bookmark.folder_id != folder.id
      bookmark.folder_id = folder.id
      bookmark.save
      puts "LOGGER"
      puts bookmark
      puts bookmark.id
      puts bookmark.folder_id
    end

    folder

  end

  def moveToLocation(targetLocation)
    targetStorage = targetLocation.storage
    amfiles = mfiles.select { |mfile| mfile.mtype != 8 } # folder
    fSource = amfiles.map { |mfile| mfile.path(2) }
    fSourceTN = amfiles.map { |mfile| mfile.path(4) }

    targetStorage.folders << self
    fTarget = amfiles.map { |mfile| mfile.path(2) }
    fTargetTN = amfiles.map { |mfile| mfile.path(4) }

    FileHandler.moveFiles(fSource, fTarget)
    FileHandler.moveFiles(fSourceTN, fTargetTN)
  end

  def enhance
    result = Fit.matchAndScan(bookmark.url, 1)[1]
    folderAttris = []
    result.each do |f|
      if (f[:action] == 6)
        folderAttris << f[:link]
      end
    end
    addAttris(folderAttris);

    mfiles = Mfile.where(mtype: Mfile::MFILE_FOLDER)
    #  Folder.where("mfile_id > :x",{x: 0})

  end

  def enhanceTry
    x1 = "https://<>/profile/"
    y1 = "/galleries"
    x2 = "https://<>/pictures/"
    y2 = "/"
    bookmark = Bookmark.find_by(folder_id: id)

    a = mpath.split("/")
    unless bookmark
      bookmark = {url: x2 + a[2] + y2, title: "", bookmark_id: nil}
      bookmark = Bookmark.newOnly(bookmark)
      bookmark.folder_id = id
      bookmark.save
    end
    if bookmark
      unless bookmark.bookmark_id
        bm1 = {url: x1 + a[1] + y1, title: "", bookmark_id: nil}
        bm1 = Bookmark.newOnly(bm1)
        bm1.getTitle(true)
        bookmark.bookmark_id = bm1.id
        bookmark.save

      end
      bookmark.url = bookmark.url.sub("http://", "https://")
      bookmark.save
      title = bookmark.getTitle(true)
      self.title = title
      self.save
      self
    end

  end


  def addAttris(folderAttris)
    if mfile_id == nil
      mfile = Mfile.create(mtype: Mfile::MFILE_FOLDER, title: title, folder_id: id)
      self.mfile_id = mfile.id
    else
      begin
        mfile = Mfile.find(mfile_id)
      rescue
        mfile = Mfile.create(mtype: Mfile::MFILE_FOLDER, title: title, folder_id: id)
        self.mfile_id = mfile.id
      end
    end
    agroup = Agroup.find_or_create_by(name: "imagefap") # todo replace by prop_config

    folderAttris.each do |fa|
      attri = Attri.find_or_create_by(name: fa, agroup_id: agroup.id)
      if attri && !mfile.attris.exists?(attri.id)
        mfile.attris << attri
      end
    end
    mfile.save
    if (!self.save)
      blubber
    end
    self
  end

  def createYoutubeDownloader(url)
    command = "youtube-dl --write-all-thumbnails -i -w "
    command += "--skip-download "
    command = command + "-o \"\%(title)s-\%(upload_date)s-\%(id)s.\%(ext)s\" " + url
    puts command
    FileHandler.createFolder(File.join(path(2), "dummy"))
    Dir.chdir(path(2)) { system(command) }

    command = "..\\youtube-dl.exe --write-all-thumbnails -i -w "
    command = command + "-o \"%%(title)s-%%(upload_date)s-%%(id)s.%%(ext)s\" " + url
    downloadTubesFile = File.join(path(2), "download tubes.bat")
    FileHandler.createFolder(downloadTubesFile)
    File.open(downloadTubesFile, 'w') { |file| file.write(command) }

    command = "..\\youtube-dl.exe --write-all-thumbnails -i -w --skip-download "
    command = command + "-o \"%%(title)s-%%(upload_date)s-%%(id)s.%%(ext)s\" " + url
    downloadPicsFile = File.join(path(2), "download pics.bat")
    File.open(downloadPicsFile, 'w') { |file| file.write(command) }

  end

end

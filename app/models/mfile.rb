class Mfile < ActiveRecord::Base
  serialize :filename # fix for issue with UTF8 with only 3 bytes issue in mysql

#  has_and_belongs_to_many :agroups
  belongs_to :folder, optional: true
  has_one :bookmark, :dependent => :destroy
  has_and_belongs_to_many :attris
  has_many :proberties, :dependent => :destroy

  URL_STORAGE_WEB = 1
  URL_STORAGE_FS = 2
  URL_STORAGE_WEBTN = 3
  URL_STORAGE_FSTN = 4

  MFILE_UNDEFINED = 0
  MFILE_LOCATION = 1
  MFILE_PHOTO = 2  # Fotos und Videos selbst gedreht
  MFILE_MOVIE = 3  # Filme aus Kino und Fernsehen
  MFILE_BOOK = 4  # Ebooks
  MFILE_IMEDIUM = 5
  MFILE_BOOKMARK = 6 # Bookmarks
  MFILE_YOUTUBE = 7 # Youtube
  MFILE_FOLDER = 8  # Folder
  MFILE_PERSONAL_PHOTO = 10
  MFILE_PERSONAL_VIDEO = 11


  def downloadable
    return folder.downloadable
  end

  def download
    source = originPath
    target = path(URL_STORAGE_FS)
    if downloadable
      responseCode = FileHandler.download(source, target, nil, 2000)
      generateTn
      return {source: source, target: target, responseCode: responseCode}
    else
      return {source: source, target: target, responseCode: 999}
    end
  end

  def fileExistonFS?
    FileHandler.fileExistonFS(path(URL_STORAGE_FS))
  end

  def tnExistonFS?
    FileHandler.fileExistonFS(path(URL_STORAGE_FSTN))
  end

  def generateTn
    FileHandler.generateTn(path(URL_STORAGE_FS), path(URL_STORAGE_FSTN))
  end

  def path(typ)
    f = filename.gsub(/\?.*/,"")
    if folder
      if (typ == URL_STORAGE_FS or typ == URL_STORAGE_FSTN)
        if filename == nil
          adfe
        end
        if folder.path(typ) == nil
          aeee
        end
        p = File.join(folder.path(typ), f) #   typ <> web
      else
        p = File.join(folder.path(typ), URI.escape(f)) #  typ == web
      end

      if (typ == URL_STORAGE_WEBTN or typ == URL_STORAGE_FSTN)
        p.gsub!(/\.[\w]*$/, ".jpg") # Assuming Thumbnails to be always jpg's
      end

      p
    else
      "<no folder>"
    end
  end

  def originPath
    p = folder.originPath + "" + filename
#    if pdf? and (typ == URL_STORAGE_WEBTN  or typ == URL_STORAGE_FSTN)
#      p.gsub!(".pdf", ".jpg")
#    end
    p
  end

  def name
    if mtype == MFILE_BOOKMARK
      bookmark.title + " *"
    else
      filename
    end
  end

  def pic?
    name.end_with?("jpg") || name.end_with?("gif") || name.end_with?("jpeg") || name.end_with?("JPG")
  end

  def pdf?
    name.end_with?("pdf") || name.end_with?("PDF")
  end

  def mp3?
    name.end_with?("mp3") || name.end_with?("MP3")
  end


  def mtypee
    mtype == 0 ? folder.storage.mtype : 0
  end

  def youtubeLink
    fwo = filename.gsub(/\.[\w]*$/, "")[-11..-1]
    if fwo
      youtube_id = fwo[-11..-1]
      "https://www.youtube.com/watch?v=" + youtube_id
      "https://www.youtube.com/embed/" + youtube_id
    else
      "n/a"
    end
  end

  def self.cutFilenames(result, folder, location)
    offsetLength = folder.mpath.length + location.uri.length
    result.each { |f|
      if f[:action] == 1
        url = f[:link]
        ldiff = offsetLength - url.length # is negativ!
        f[:filename] = url[ldiff..-1]
      end
    }
  end

  def self.createFrom(result, folder, location)

    offsetLength = folder.mpath.length + location.uri.length
    mf = []
    mfile = nil
    newMfile = false
    isName = false
    proberty = nil

    result.each { |f|
      if f[:action] == 1
#          url = f[:link]
#          ldiff = offsetLength - url.length # is negativ!
#          filename = url[ldiff..-1]
        filename = f[:filename]

        mfile = Mfile.find_or_create_by(folder_id: folder.id,
                                        filename: filename) do |mfile|
          mfile.mtype = Mfile::MFILE_IMEDIUM # 20171015
          mfile.mtype = folder.storage.mtype
          mf << mfile
        end
        isName = true
        mfile.proberties.destroy_all
      end

      if f[:action] == 5 && mfile
        if f[:prop_config] == "<alternating>"
          if isName
            proberty = Proberty.new
            if f[:link] != ""
              proberty.name = f[:link]
              isName = !isName
            end
          else
            proberty.value = f[:link]
            mfile.proberties << proberty
            mfile.save
            isName = !isName
          end

        else
          proberty = Proberty.new
          proberty.name = f[:prop_config]
          proberty.value = f[:link].gsub("_", " ")
          mfile.proberties << proberty
          mfile.save
        end
      end
    }
    mf

    mf.each { |mfile|
      title = ""
      mfile.proberties.each { |p|
        if (p.name == "Title")
          mfile.title = p.value
          mfile.save
        end
      }
    }
  end

  def linkedFolder
    Folder.find_by_mfile_id(id).first
  end

  def deleteFromFS
    if mtype != MFILE_FOLDER
      if fileExistonFS?
        FileHandler.deleteFile(path(URL_STORAGE_FS))
      end
      if tnExistonFS?
        FileHandler.deleteFile(path(URL_STORAGE_FSTN))
      end
    end
  end
end




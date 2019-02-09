class Mfile < ActiveRecord::Base
  serialize :filename # fix for issue with UTF8 with only 3 bytes issue in mysql

#  has_and_belongs_to_many :attris
#  has_and_belongs_to_many :agroups
  belongs_to :folder
  has_one :bookmark, :dependent => :destroy

  URL_STORAGE_WEB = 1
  URL_STORAGE_FS  = 2
  URL_STORAGE_WEBTN = 3
  URL_STORAGE_FSTN  = 4
  
MFILE_UNDEFINED = 0
MFILE_LOCATION = 1
MFILE_PHOTO = 2
MFILE_MOVIE = 3
MFILE_BOOK = 4
MFILE_IMEDIUM = 5
MFILE_BOOKMARK = 6
MFILE_YOUTUBE = 7


  def downloadable
    return folder.downloadable   
  end

  def download
     source = originPath
     target = path(URL_STORAGE_FS)
     if downloadable
        responseCode = FileHandler.download(source, target,nil,2000)
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
      FileHandler.generateTn(path(URL_STORAGE_FS),path(URL_STORAGE_FSTN))
  end

  def path(typ)
      if folder
        if (typ == URL_STORAGE_FS  or typ == URL_STORAGE_FSTN)
           p =  File.join(folder.path(typ), filename) #   typ <> web
        else
           p =  File.join(folder.path(typ), URI.escape(filename)) #  typ == web
        end

        if (typ == URL_STORAGE_WEBTN  or typ == URL_STORAGE_FSTN)
           p.gsub!(/\.[\w]*$/, ".jpg")  # Assuming Thumbnails to be always jpg's 
        end
         
        p
     else
        "<no folder>"
     end
  end

  def originPath
    p =  folder.originPath + ""+ filename
    if pdf? and (typ == URL_STORAGE_WEBTN  or typ == URL_STORAGE_FSTN)
      p.gsub!(".pdf", ".jpg")
    end
    p
  end

   def name
       if mtype == MFILE_BOOKMARK
          bookmark.title+" *"
       else
         filename
       end
   end
 
  def pic?
    name.end_with?("jpg") || name.end_with?("gif") ||  name.end_with?("jpeg") || name.end_with?("JPG")
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
       "https://www.youtube.com/watch?v="+youtube_id
       "https://www.youtube.com/embed/"+youtube_id
      else
        "n/a"
      end
  end
  
  def self.createFrom(result, folder,location)

      offsetLength = folder.mpath.length + location.uri.length

      result.each {|url, assess|
        if assess[:action] == 1
          ldiff = offsetLength - url.length # is negativ!
          filename = url[ldiff..-1]

          Mfile.find_or_create_by(folder_id: folder.id, 
                                  filename: filename) do |mfile|
              mfile.mtype = Mfile::MFILE_IMEDIUM # 20171015
          end
        end
       }
  end
end

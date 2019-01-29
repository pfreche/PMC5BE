require 'uri'
require 'net/http'

class FileHandler

  def self.deleteFile(file)
      File(file).delete  
  end

  def self.download(source, target, referer = nil, minsize = 0)

     self.createFolder(target)
  
     if !File.exist?(target) or File.size(target) <  minsize
   
  	      uri = URI.parse(URI.encode(source))
          req = Net::HTTP::Get.new(uri.request_uri)
          r = 0
          if referer == nil
             req['Referer'] = uri.scheme+"://"+uri.host
          else
             req['Referer'] = referer
          end
          Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
              response = http.request(req)
              open(target, "wb") do |file|
                  r = response.code
                  if ( r == "200" or true)
                     file.write(response.body) 
                  end

              end
          end
          r
     else
       File.size(target).to_s+"  "+ minsize.to_s
     end
  end


  def self.download2(source, target, referer = nil, minsize = 0 )

          self.createFolder(target)
          if !File.exist?(target) or File.size(target) >  minsize
            uri = URI.parse(URI.encode(source))
            referer = uri.scheme + "://"+uri.host
            @curl = "curl -e \"" + referer +  "\""
            @curl =  @curl + " -o \""+ target + "\" \"" + source +  "\""
#            `@curl`
            system(@curl)
            "hhhhh"
          else
          	"no Download since file size >"+minsize
          end
  end
  
  def self.fileExistonFS(file)
    File.exist?(file)
  end

  def self.generateTn(file,tnFile, area=20000)
     self.createFolder(tnFile)
     command = "convert \""+ file + "\" -thumbnail "+area.to_s+"@ \""+ tnFile+"\""
     if command
        system(command)
     end
  end

  def self.createFolder(file)
  	  fsplit = File.dirname(file).split(/\//)
      fr = ""
      fsplit.each do |fs|
        next if fs == ""
        fr = File.join(fr,fs)
        unless File.exist?(fr)
          Dir.mkdir(fr)
        end
      end
  end

  def self.dir(path)
  	Dir.entries(path)
  end


  def self.loadUrl(u)
    
    Rails.cache.fetch(u, expires_in: 12.hours) do 

        begin
#         open(u).read  

         uri = URI(u)
         Net::HTTP.get(uri)
        end
    end
 
  end


end



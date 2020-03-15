require 'uri'
require 'net/http'

class FileHandler

  def self.deleteFile(file)
      File.delete(file)
  end

  def self.deleteDirectory(dir)
    FileUtils.remove_dir(dir) if File.directory?(dir)
  end

  def self.download(source, target, referer = nil, minsize = 0)

     self.createFolder(target)
  
     if !File.exist?(target) or File.size(target) <  minsize
   
  	      uri = URI.parse(URI.encode(source))
          req = Net::HTTP::Get.new(uri.request_uri)
          r = 0
          if referer == nil
#             req['Referer'] = uri.scheme+"://"+uri.host
          else
#             req['Referer'] = referer
          end
          puts uri.host
          puts uri.port
          puts uri.scheme
#  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL:VERIFY_NONE
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
          if !File.exist?(target) or File.size(target) <  minsize
            uri = URI.parse(URI.encode(source))
            referer = uri.scheme + "://"+uri.host
            @curl = "curl -e \"" + referer +  "\""
            @curl =  @curl + " -o \""+ target + "\" \"" + source +  "\""
#            `@curl`
            system(@curl)
            "hhhhh"
          else
          	"no Download since file size >" + minsize.to_s
          end
  end
  
  def self.fileExistonFS(file)
    File.exist?(file)
  end

  def self.generateTn(file,tnFile, area=50000)
     self.createFolder(tnFile)
     if  file.end_with?("pdf") || file.end_with?("PDF")
      command = "convert \""+ file + "[0]\" -thumbnail "+area.to_s+"@ \""+ tnFile+"\""
     else
       command = "convert \""+ file + "\" -thumbnail "+area.to_s+"@ \""+ tnFile+"\""
     end
     if command
        system(command)
     end
     command
  end

  def self.createFolder(file)
      puts file
  	  fsplit = File.dirname(file).split(/\//)
      fr = ""
      fsplit.each do |fs|
        next if fs == ""
        fr = File.join(fr,fs)
        puts fr
        unless File.exist?(fr)
          Dir.mkdir(fr)
        end
      end
  end

  def self.dir(path)
  	files = Dir.entries(path).select{|f| f!="."}
    files.sort.map{|file| {file: file, isDir: File.directory?(File.join(path,file))}}
  end

  def self.dirDeep(path,pattern) #todo for pattern
    Dir.chdir(path)
    Dir.glob("**/*").reject do |path|
      File.directory?(path) || path.include?("@eaDir")
    end
  end

def self.scan(path, filter)

    level =   path.split(/\//).length
    path = File.join(path,"/**/*")
    
    files = []
    if filter == nil
      filter  = "."
    end
    Dir.glob(path) {|f|
      if !File.directory?(f) and f[%r{#{filter}}]
        files << f
      end
      }
    files.sort_by!{ |f| File.mtime(f)}
    k = files.reverse.map {|l| 
      l.split(/\//)[level,100]
    }
    {level: level, a: path,b: k}
end

def self.moveFiles(fSource,fTarget)
  fSource.zip(fTarget).each do |source, target|
    if (File.exist?(source))
       FileHandler.createFolder(target)
       command = "mv \"" + source + "\" \"" + target + "\""
       system(command)      
       puts command
    end
  end
end


  def self.loadUrl(u)
    
    Rails.cache.fetch(u, expires_in: 48.hours) do 

        begin
#         open(u).read  

         uri = URI(URI.escape(u))
         Net::HTTP.get(uri)
        end
    end
 
  end


end



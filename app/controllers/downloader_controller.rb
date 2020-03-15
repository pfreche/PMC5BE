class DownloaderController < ApplicationController
  def downloadYoutubeVideo
    youtubeUrl = params[:youtubeUrl]
    targetFolder = params[:targetFolder]
    youtubeId = youtubeUrl.slice(32..41)
    if youtubeUrl && targetFolder
     command = "youtube-dl "
      command = command + youtubeUrl
      Dir.chdir(targetFolder) do
        system(command)
        files = Dir.entries(targetFolder).select{|f| f[youtubeId]}
        file = files[0]
        redirecUrl = "http://192.168.178.21/video/BinisYoutube/"+file
        redirect_to redirecUrl
      end
    else
      render plain: "Sorry, Leider ist ein Fehler aufgetreten."
    end


  end
end

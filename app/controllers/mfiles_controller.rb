class MfilesController < ApplicationController

  before_action :set_mfile, only: [:show, :download, 
  	:fileExistonFS, :tnExistonFS, :generateTn,
  	:youtubeLink, :update, :destroy, :add_attri, :add_attri_name, :remove_attri, :add_agroup, :remove_agroup, :renderMfile, :download]

  def index
  	  @mfiles = Mfile.includes(:folder).limit(40)
     render json: @mfiles.as_json(:include => :folder)
  end

  def show
     render json: @mfile.as_json(:include => :folder)
  end

  # GET /mfiles/new
  def new
    @mfile = Mfile.new
  end

  def indexByFolder
     folder_id = params[:id]
     @mfiles = Mfile.includes(:folder).where(folder_id: folder_id) 
     render json: @mfiles.as_json(:include => :folder)
  end
  
  def download
      d = @mfile.download
      render json: d 
  end

  def generateTn
      d = @mfile.generateTn
      render json: d 
  end

  def fileExistonFS
      render json: {fileExistonFS: @mfile.fileExistonFS?}
  end

  def tnExistonFS
      render json: {tnExistonFS: @mfile.tnExistonFS?}
  end
  
  def dl
      url = params[:url]
      referer = params[:referer]
      FileHandler.download(params[:url],"/media/imagefap/a.txt", referer)
  end


  def set_mfile
    @mfile = Mfile.includes(:folder).find(params[:id])
  end


end

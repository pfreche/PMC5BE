class MfilesController < ApplicationController

  before_action :set_mfile, only: [:show, :download, 
  	:fileExistonFS, :tnExistonFS, :generateTn, :destroy,
  	:youtubeLink, :update, :destroy, :add_attri, :add_attri_name, :remove_attri, :add_agroup, :remove_agroup, :renderMfile, :download]

  def index
    if params[:attri_id]
      @mfiles = Attri.find(params[:attri_id]).mfiles
       render json: @mfiles.as_json(:include => :folder)
    else
      @mfiles = Mfile.includes(:folder).limit(40)
      render json: @mfiles.as_json(:include => :folder)
    end
  end

  def show
    class << @mfile
      attr_accessor :url
    end
     @mfile.url = "blalbal"
     render json: @mfile.as_json(:include => [:folder, :proberties, :attris, :bookmark])
  end

  def destroy
    @mfile.destroy
    render text: "destroyed"
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
      render json: {"command": d}
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
      FileHandler.download(params[:url],"/media/if/a.txt", referer)
  end

  def add_attri
    attri = Attri.find(params[:attri_id])
    if attri  && !@mfile.attris.exists?(attri.id)
       @mfile.attris << attri
    end
    render json: @mfile.attris
  end

  def remove_attri
    attri = Attri.find(params[:attri_id])
    if attri  && @mfile.attris.exists?(attri.id)
       @mfile.attris.destroy(attri)
    end
    render json: @mfile.attris
  end

  def set_mfile
    @mfile = Mfile.includes(:folder).includes(:proberties).includes(:attris).find(params[:id])
  end


end

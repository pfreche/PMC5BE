class MediaController < ApplicationController

  before_action :set_medium, only: [:show, :showFull, :download,
  	:fileExistonFS, :tnExistonFS, :generateTn, :destroy,
  	:youtubeLink, :update, :destroy, :add_attri, :add_attri_name, :remove_attri, :add_agroup, :remove_agroup, :rendermedium, :download]

  def index
    if params[:attri_id]
      @media = Attri.find(params[:attri_id]).media
       render json: @media.as_json
    else
      @media = Medium.includes(:group).limit(100)
      render json: @media.as_json(:include => :group)
    end
  end

  def show #ok
     render json: @medium.as_json(:include => [:group, :proberties, :attris, :meFiles])
  end

  def showFull
    redirect_to  @medium.fqNameCleaned(1)
    # render json: {name: @medium.fqNameCleaned(1)}
  end

  def destroy
    @medium.destroy
    render text: "destroyed"
  end

  # GET /mediums/new
  def new
    @medium = Medium.new
  end

  def indexByFolder  # obsolete > replaced by groups controller method "media"
     folder_id = params[:id]
     @mediums = medium.includes(:folder).where(folder_id: folder_id)
     render json: @media.as_json(:include => :folder)
  end

  def download
      d = @medium.download
      render json: d
  end

  def generateTn
      d = @medium.generateTn
      render json: {command: d}
  end

  def fileExistonFS
      render json: {fileExistonFS: @medium.fileExistonFS?}
  end

  def tnExistonFS
      render json: {tnExistonFS: @medium.tnExistonFS?}
  end

  def dl
      url = params[:url]
      referer = params[:referer]
      FileHandler.download(params[:url],"/media/if/a.txt", referer)
  end

  def add_attri
    attri = Attri.find(params[:attri_id])
    if attri  && !@medium.attris.exists?(attri.id)
       @medium.attris << attri
    end
    render json: @medium.attris
  end

  def remove_attri
    attri = Attri.find(params[:attri_id])
    if attri  && @medium.attris.exists?(attri.id)
       @medium.attris.destroy(attri)
    end
    render json: @medium.attris
  end

  def set_medium
    @medium = Medium.includes(:group).includes(:proberties).includes(:attris).find(params[:id])
  end


end

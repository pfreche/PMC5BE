class mediumsController < ApplicationController

  before_action :set_medium, only: [:show, :download,
  	:fileExistonFS, :tnExistonFS, :generateTn, :destroy,
  	:youtubeLink, :update, :destroy, :add_attri, :add_attri_name, :remove_attri, :add_agroup, :remove_agroup, :rendermedium, :download]

  def index
    if params[:attri_id]
      @mediums = Attri.find(params[:attri_id]).mediums
       render json: @mediums.as_json(:include => :folder)
    else
      @media = Medium.includes(:folder).limit(40)
      render json: @mediums.as_json(:include => :folder)
    end
  end

  def show
     render json: @medium.as_json(:include => [:folder, :proberties, :attris, :bookmark])
  end

  def destroy
    @medium.destroy
    render text: "destroyed"
  end

  # GET /mediums/new
  def new
    @medium = Medium.new
  end

  def indexByFolder
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
      render json: {"command": d}
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
    @medium = Medium.includes(:folder).includes(:proberties).includes(:attris).find(params[:id])
  end


end

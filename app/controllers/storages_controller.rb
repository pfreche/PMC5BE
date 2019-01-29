class StoragesController < ApplicationController
  
  before_action :set_storage, only: [:show, :downloadable]

  def index
     @storages = Storage.all
     render json: @storages
  end

  def show
     render json: @storage.as_json(:include => :locations)
  end

  def downloadable
     render json: {downloadable: @storage.downloadable}
  end

  def set_storage
    @storage = Storage.includes(:locations).find(params[:id])
  end

end

class StoragesController < ApplicationController
  
  before_action :set_storage, only: [:show, :downloadable, :locations, :update]

  def index
     @storages = Storage.all
     render json: @storages
  end

  def show
     render json: @storage.as_json(:include => :locations)
  end

  def create
    @storage = Storage.new(storage_params)
    if @storage.save
        render json: @storage 
   else
       render json: @storage.errors, status: :unprocessable_entity
    end
   end
 
   def update
      if @storage.update(storage_params)
         @storage.save
         render json: @storage
      end
   end
 
   def destroy
    @storage = Storage.find(params[:id])
#    @storage.destroy  //  dont wanna risk accidents
    render json: @storage
 #   "[destroyed: 'yes']"
   end
 

   def deepCopy
      @storage = Storage.find(params[:id])
      storageNew = @storage.deepCopy
      render json: storageNew
   end

   def inheritMtype
      @storage = Storage.find(params[:id])
      storage = @storage.inheritMtype
      render json: storage
   end

  
  def downloadable
     render json: {downloadable: @storage.downloadable}
  end

  def locations
    locations =  @storage.locations
    render json: locations   
  end

  def set_storage
    @storage = Storage.includes(:locations).find(params[:id])
  end

  def storage_params
    params.require(:storage).permit(:name, :mtype, :fit_id)
  end

end

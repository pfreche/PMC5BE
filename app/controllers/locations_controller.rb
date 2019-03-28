class LocationsController < ApplicationController

before_action :set_location, only: [:show, :edit, :update]

def index
    @locations = Location.all.order(:storage_id)
    render json: @locations
end

  
  def show
     render json: @location
  end

  def create
   @location = Location.new(location_params)
   if @location.save
       render json: @location 
  else
      render json: @location.errors, status: :unprocessable_entity
   end
  end

  def update
     if @location.update(location_params)
        @location.save
        render json: @location
     end
  end

  def destroy
   @location = Location.find(params[:id])
   @location.destroy
   render json: @location
#   "[destroyed: 'yes']"
  end

  def dir
   relpath = params[:relpath] || ""
   id = params[:id]
   @location = Location.find(id)
   dirlist = @location.dir(relpath)
   render json: dirlist
  end

  def addFolder
    relpath = params[:relpath] || ""
    id = params[:id]
    @location = Location.find(id)
    folder = @location.addFolder(relpath)
    if folder 
      mfiles = @location.scanMfiles(folder,"")
      render json: mfiles
   end
  end

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
      params.require(:location).permit(:name, :uri, :description, :storage_id, :typ, :inuse, :origin)
  end

end


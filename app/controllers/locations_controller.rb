class LocationsController < ApplicationController

before_action :set_location, only: [:show, :edit, :update]

def index
    @locations = Location.all.order(:storage_id)
    render json: @locations
end



  def show
     render json: @location
  end

  def update
     if @location.update(location_params)
        @location.save
        render json: @location
     end
  end

  def set_location
    @location = Location.find(params[:id])
  end

  def location_params
      params.require(:location).permit(:name, :uri, :description)
  end

end


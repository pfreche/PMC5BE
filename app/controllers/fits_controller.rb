class FitsController < ApplicationController
  

  before_action :set_fit, only: [:show, :bookmarks, :destroy, :tworkers] 

  def index
  	  @fits = Fit.all
  	  render json: @fits
  end

  def show
     render json: @fit
  end

  def new
    @fit = Fit.new
    render json: @fit
  end

  def create
      @fit = Fit.new(fit_params)
      logger.fatal params.to_s
     if @fit.save
          render json: @fit 
     else
         render json: @fit.errors, status: :unprocessable_entity
      end
  end

  def update
      @fit = Fit.find(params[:id])
     if @fit.update(fit_params)
     @fit.save
      render json: @fit 
     end
  end

  def destroy
      @fit.destroy
      render json: @fit
   #   "[destroyed: 'yes']"
  end

  def bookmarks
      bookmarks = @fit.matchingBookmarks
      render json: bookmarks
  end

  def tworkers
      render json: @fit.tworkers
  end

  def scanUrl
      url = params[:url]
      level = params[:level]
      if level
        result = Fit.matchAndScan(url, level.to_i)
       else
        result = Fit.scanUrl(url)
      end
      if params[:locate]
        loc = Fit.detCommonStart(result)
        locations = Fit.locations(loc)
        render json: {commonstart: loc, locations: locations}
      else

      render json: result.to_a
      end
  end
  
  def scanAndSave
     url = params[:url]
     location_id = params[:location_id]
     folder = Fit.scanAndCreateFolderAndMfiles(url,location_id)
     render json: folder
     
  end


  private

  def set_fit
    @fit = Fit.find(params[:id])
  end

    def fit_params
      params.require(:fit).permit(:id, :pattern, :bookmark_id)
    end

end

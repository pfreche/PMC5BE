class TworkersController < ApplicationController


  before_action :set_tworker, only: [:show, :bookmarks, :destroy] 

  def index
  	  @tworkers = Tworker.all.order("fit_id ASC")
  	  render json: @tworkers.as_json(:include => :fit)
  end

  def show
      id = params[:id]
      @tworker = Tworker.includes(:fit).find(id) 
      render json: @tworker.as_json(:include => :fit)
  end

  def new
    @tworker = tworker.new
    render json: @tworker
  end

  def create
      @tworker = Tworker.new(tworker_params)
      logger.fatal params.to_s
     if @tworker.save
          render json: @tworker 
     else
         render json: @tworker.errors, status: :unprocessable_entity
      end
  end

  def update
      @tworker = Tworker.find(params[:id])
     if @tworker.update(tworker_params)
     @tworker.save
      render json: @tworker 
     end
  end

  def destroy
      @tworker.destroy
      render json: @tworker
  end

  def scanBookmark
      id = params[:id]
      bookmark_id = params[:bookmark_id]
      @tworker = Tworker.find(id) 
      @bookmark = Bookmark.find(bookmark_id) 
      
      a = @tworker.scanUrl(@bookmark.url)
      render json: {text: a}
  end

  private

  def set_tworker
    @tworker = Tworker.find(params[:id])
  end

    def tworker_params
      params.require(:tworker).permit(:id, :name, :pattern, :formular, :fit_id, :tag, :attr, :final, :action, :prop_config)
    end

end

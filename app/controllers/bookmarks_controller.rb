class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy, :getTitle, :scan, :linkFolder,:unlink, :fit,:addSuffix, :modulateURL]

  def index
    if search = params[:search]
      bookmarks = Bookmark.where('url LIKE ?  or title LIKE ?',"%"+search+"%","%"+search+"%").order("id DESC")
    else
    	bookmarks = Bookmark.all.order("id DESC")
    end
    render json: bookmarks.to_json
    
  end

  def show
    render json: @bookmark
  end 

  def getTitle
    render plain: @bookmark.getTitle
  end


  def create
 //     if b = Bookmark.find_by(url: params[:url])
      if b = Bookmark.where('url LIKE ?',params[:url]+"%").first
          render status: 210, json: b
      else 
         @bookmark = Bookmark.new(bookmark_params)
      logger.fatal params.to_s
      
      @bookmark.folder_id  = 0
      @bookmark.bookmark_id  = nil
      
      if @bookmark.save
          render json: @bookmark 
     else
       render json: @bookmark.errors, status: :unprocessable_entity
      end
    end
  end

  def update
      @bookmark = Bookmark.find(params[:id])
     if @bookmark.update(bookmark_params)
       @bookmark.save
       @bookmark.updateFolderTitle
       render json: @bookmark 
     end
  end

  def destroy
      @bookmark = Bookmark.find(params[:id])
      @bookmark.destroy
      render json: @bookmark
   #   "[destroyed: 'yes']"
  end

  
  def fit
     fits = Fit.findFits(@bookmark.url)
     render json: fits
  end

  def addSuffix
    suffix = params[:suffix]
    if suffix && !@bookmark.url.end_with?(suffix)
      @bookmark.url = @bookmark.url+suffix
      @bookmark.save
    end
    render json: @bookmark
  end

  def modulateURL
    Fit.transformBookmark(@bookmark)
    render json: @bookmark
  end

  def domains  
     render json: Bookmark.domains
  end

  def findByDomain
      domain = params[:domain]
      bookmarks = Bookmark.findByDomain(domain)
      render json: bookmarks
  end
  
  def getChildren
     bookmarks = Bookmark.where(:bookmark_id => params[:id])
     render json: bookmarks
    end
#  attri stuff

  def addAttri 
  end

  def getAttris
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bookmark
      @bookmark = Bookmark.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bookmark_params
      params.require(:bookmark).permit(:title, :url, :description,:search, :suffix)
    end
end

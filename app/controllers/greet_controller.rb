class GreetController < ApplicationController
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy, :getTitle, :scan, :linkFolder,:unlink]

  def index
  	bookmarks = Bookmark.all.order("id DESC")
    render json: bookmarks
  end

  def show
    render json: @bookmark
  end

  def getTitle

    @bookmark = Bookmark.new(bookmark_params)
    uri = URI.parse(@bookmark.url)
    begin
#      response = Net::HTTP.get_response(uri)
      page = Nokogiri::HTML(open(@bookmark.url))
      @title = page.css("title")[0].text
    rescue StandardError
      @title = "site not available: " + @bookmark.url
    end
    render plain: @title
  end


  def create
      @bookmark = Bookmark.new(bookmark_params)
#      @bookmark = Bookmark.new
      logger.fatal params.to_s
 #     @bookmark.title = params[:title]

#     @bookmark.title = params.to_s
      
#      @bookmark.folder_id  = 13
      @bookmark.mfile_id  = 1
      
      if @bookmark.save
          render json: @bookmark 
     else
         render json: @bookmark.errors, status: :unprocessable_entity
      end
  end

  def update
      @bookmark = Bookmark.find(params[:id])
#      @bookmark.description = "updated 710"
     if @bookmark.update(bookmark_params)
     @bookmark.save
      render json: @bookmark 
     end
  end

  def destroy
      @bookmark = Bookmark.find(params[:id])
      @bookmark.destroy
      render json: @bookmark
   #   "[destroyed: 'yes']"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bookmark
      @bookmark = Bookmark.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bookmark_params
      params.require(:greet).permit(:title, :url, :description)
    end
end

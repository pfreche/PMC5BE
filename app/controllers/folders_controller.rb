class FoldersController < ApplicationController

 def index
    @folders = Folder.all.order(:id).limit(2000)
     render json: @folders
 end

  def indexByStorage
     storage_id = params[:id]
     @folders = Folder.where(storage_id: storage_id) 
     render json: @folders
  end

  def number
     @number = Folder.count
     render json: {number:  @number}
  end

  def show
     id = params[:id]
     @folder = Folder.includes(:bookmark).find(id) 
     render json: @folder.as_json(:include => :bookmark)

  end

  def dir
     relpath = params[:relpath] || ""
     id = params[:id]
     @folder = Folder.find(id) 
     dirlist = @folder.dir(relpath)
     render json: dirlist
  end

  def scan
     relpath = params[:relpath] || ""
     id = params[:id]
     @folder = Folder.find(id) 
     dirlist = @folder.scan(relpath)
     render json: dirlist
  end

end

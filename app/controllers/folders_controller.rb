class FoldersController < ApplicationController

  def index
    if params[:title]
      @folders = Folder.all.order(:title).limit(5000)
    else
      @folders = Folder.all.order(:id).limit(5000)
    end
    render json: @folders
  end

  def indexByStorage
    storage_id = params[:id]
    @folders = Folder.where(storage_id: storage_id)
    render json: @folders
  end

  def number
    @number = Folder.count
    render json: {number: @number}
  end

  def show
    id = params[:id]
    @folder = Folder.includes(:bookmark).find(id)
#     mfile = Mfile.find(@folder.mfile_id)
#     mfile.folder_id = id
#     mfile.save
    render json: @folder.as_json(:include => :bookmark)
  end

  def remove
    folder = Folder.find(params[:id])
    folder.destroy
    render text: "folder removed"
  end

  def destroy
    folder = Folder.find(params[:id])
#   folder.deleteFromFS
    folder.deletePhysicalFilesFromFS
    folder.destroy
    render text: "folder removed and files deleted"
  end

  def removeMfilesWOPhysicalFile
    folder = Folder.find(params[:id])
    folder.removeMfilesWOPhysicalFiles
    render json: folder
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

  def enhance
    id = params[:id]
    @folder = Folder.find(id)
    result = @folder.enhance
    render json: result
  end


  def scanAndAddFromOriginLocation
    id = params[:id]
    folder = Folder.find(id)
    if folder
      folder = Fit.scanAndCreateMfiles(folder)
    end
    render json: folder
  end

  def moveToLocation

    id = params[:id]
    folder = Folder.find(id)
    if folder
      targetLocation_id = params[:targetLocation_id]
      targetLocation = Location.find(targetLocation_id)
      if targetLocation
        c = folder.moveToLocation(targetLocation)
      end
    end
    render json: c

  end

end

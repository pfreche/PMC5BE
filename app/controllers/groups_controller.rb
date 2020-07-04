class GroupsController < ApplicationController

  def index
    if params[:title] # ist dies Quatsch?
      @groups = Group.all.order(:title).limit(5000)
    else
      @groups = Group.all.order(:id).limit(5000)
    end
    render json: @groups
  end

  def media
    id = params[:id]
    render json: Group.find(id).media.as_json
  end

  def indexByStorage # obsolete > wrong controller
    storage_id = params[:id]
    @groups = Group.where(storage_id: storage_id)
    render json: @groups
  end

  def number #ok
    @number = Group.count
    render json: {number: @number}
  end

  def show #ok , WIP re bookmark
    id = params[:id]
    if params[:wbm]
      @group = Group.includes(:bookmark).find(id)
      render json: @group.as_json(:include => :bookmark)
    else
      @group = Group.find(id)
      render json: @group.as_json
    end
  end

  def remove
    group = Group.find(params[:id])
    group.destroy
    render text: "group removed"
  end

  def destroy
    group = Group.find(params[:id])
#   group.deleteFromFS
    group.deletePhysicalFilesFromFS
    group.destroy
    render text: "group removed and files deleted"
  end

  def removeMfilesWOPhysicalFile
    group = Group.find(params[:id])
    group.removeMfilesWOPhysicalFiles
    render json: group
  end

  def dir
    relpath = params[:relpath] || ""
    id = params[:id]
    @group = Group.find(id)
    dirlist = @group.dir(relpath)
    render json: dirlist
  end

  def scan
    relpath = params[:relpath] || ""
    id = params[:id]
    @group = Group.find(id)
    dirlist = @group.scan(relpath)
    render json: dirlist
  end

  def enhance
    id = params[:id]
    @group = Group.find(id)
    result = @group.enhance
    render json: result
  end


  def scanAndAddFromOriginLocation
    id = params[:id]
    group = Group.find(id)
    if group
      group = Fit.scanAndCreateMfiles(group)
    end
    render json: group
  end

  def moveToLocation

    id = params[:id]
    group = Group.find(id)
    if group
      targetLocation_id = params[:targetLocation_id]
      targetLocation = Location.find(targetLocation_id)
      if targetLocation
        c = group.moveToLocation(targetLocation)
      end
    end
    render json: c

  end

end

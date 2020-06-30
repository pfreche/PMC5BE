class MeFile
  @filename
  @path  #  relative to
  @typ  # main, tn, secondary
  belongs_to MeObject
  belongs_to Storage

  def url
    # meobject.storage.location(@type).path + @path + @filename
  end
end

class MeObject
  @name
  @meType  # audio, foto, movie, bookmark, Mefolder
  belongs_to MeFolder # optional
end

class MeFolder
  @name
  @folderType # download from internet, fs for scanner, youtube
  def download
  end

  def fsScan
  end

  def internetScan # via linked bookmark and fit/worker
  end

  def

end

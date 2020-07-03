class Medium
  @name
  @mtype  # audio, foto, movie, bookmark, Mefolder
  belongs_to Group # optional
end

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


class Group
  @name
  @gtyp #download from internet, fs for scanner, youtube
  @storage_id
  def download
  end

  def fsScan
  end

  def internetScan # via linked bookmark and fit/worker
  end

  def

end

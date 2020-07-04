class Medium < ApplicationRecord
  belongs_to :group
  has_many :meFiles
  has_many :proberties, :dependent => :destroy, foreign_key: "mfile_id"
  has_and_belongs_to_many :attris, foreign_key: "mfile_id", join_table: "attris_mfiles"

  include MediaTypes


  def path(ftype)
    MeFile.find_by(medium_id: id, ftype: ftype).path
  end

  def generateTn
    generateDefaultTNMeFile
    FileHandler.generateTn(fqName(URL_STORAGE_FS), fqName(URL_STORAGE_FSTN))
  end

  def fqName(typ)
    basePath = storage.path(typ)
    if typ == URL_STORAGE_FS || typ == URL_STORAGE_FS
      p = path(1)
    else
      p = path(2)
    end
    File.join(basePath, p, name) || "<not defined>"
  end

  def fqNameCleaned(typ)
    fqName(typ).gsub(/\?.*/,"")
  end

  def generateDefaultTNMeFile
    if MeFile.where(medium_id: id, ftype: 2).blank?
      meFileMain = MeFile.find_by(medium_id: id, ftype: 1)
      MeFile.find_or_create_by({
                                   medium_id: id,
                                   name: meFileMain.name.gsub(/\?.*/,""),
                                   path: meFileMain.path,
                                   ftype: 2, # TN
                                   storage_id: meFileMain.storage_id
                               })
    end
  end
end

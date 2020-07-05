class Medium < ApplicationRecord
  belongs_to :group, optional: true  # important!
  has_many :meFiles
  has_many :proberties, :dependent => :destroy, foreign_key: "mfile_id"
  has_and_belongs_to_many :attris, foreign_key: "mfile_id", join_table: "attris_mfiles"

  include MediaTypes

  def meFile(ftype)
    MeFile.find_by(medium_id: id, ftype: ftype)
  end

  def path(ftype)
    MeFile.find_by(medium_id: id, ftype: ftype).path
  end

  def generateTn
    generateDefaultTNMeFile
    FileHandler.generateTn(fqName(URL_STORAGE_FS), fqName(URL_STORAGE_FSTN))
  end

  def fqName(stype)
    if stype == URL_STORAGE_FS || stype == URL_STORAGE_WEB
      ftype = 1
    else
      ftype = 2
    end
    mf =  meFile(ftype)
    File.join(mf.storage.path(stype), path(ftype), mf.name) || "<not defined>"
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

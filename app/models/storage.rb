class Storage < ActiveRecord::Base

  has_many :locations
  has_many :folders,  :dependent => :destroy # too risky

  def originLocation
   locations.where(storage_id: id).where(origin: true).first
  end

  def originPath
     originLocation ? originLocation.uri : nil
  end

  def downloadable 
    locations.select{|l| l.inuse && l.typ == 2}.length > 0 &&
    locations.select{|l| l.origin && l.typ == 1}.length > 0
  end

  def orginalWebLocation
    locations.select{|l| l.origin && l.typ == 1}.first 
  end

  def fsInuse
    locations.select{|l| l.inuse && l.typ == 2}.first
  end
 
  def location(typ)
     locations.where(storage_id: id).where(inuse: true, typ: typ).first
  end
  
  def path(typ)
    if l = location(typ)
      l.uri      
    else
          ""
    end
  end

end

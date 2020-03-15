class Agroup < ActiveRecord::Base
  has_and_belongs_to_many :mfiles
  has_many :attris
end

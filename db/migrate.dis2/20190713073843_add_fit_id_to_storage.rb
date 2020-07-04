class AddFitIdToStorage < ActiveRecord::Migrations[5.2]
  def change
    add_column :storages, :fit_id, :integer
  end
end

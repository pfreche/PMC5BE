class CreateMeFiles < ActiveRecord::Migrations[5.2]
  def change
    create_table :me_files do |t|
      t.string :name
      t.string :path
      t.integer :ftype
      t.integer :medium_id
      t.integer :storage_id
      t.index ["medium_id"], name: "index_medium_on_medium_id"
      t.index ["storage_id"], name: "index_storage_on_storage_id"

      t.timestamps
    end
  end
end

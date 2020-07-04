class CreateGroups < ActiveRecord::Migrations[5.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.integer :gtype
      t.string :path
      t.integer :medium_id
      t.integer :storage_id
      t.index ["storage_id"], name: "index_storage_on_storage_id"
      t.index ["medium_id"], name: "index_medium_on_medium_id"

      t.timestamps
    end
  end
end

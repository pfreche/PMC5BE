class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.string :name
      t.integer :group_id
      t.integer :mtype
      t.datetime "modified"
      t.date "mod_date"
      t.index ["group_id"], name: "index_groups_on_group_id"

      t.timestamps
    end
  end
end

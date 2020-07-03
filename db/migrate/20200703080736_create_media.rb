class CreateMedia < ActiveRecord::Migration[5.2]
  def change
    create_table :media do |t|
      t.string :name
      t.integergroup_id :mtype

      t.timestamps
    end
  end
end

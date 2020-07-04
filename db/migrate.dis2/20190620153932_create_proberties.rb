class CreateProberties < ActiveRecord::Migrations[5.2]
  def change
    create_table :proberties do |t|
      t.string :name
      t.text :value
      t.integer :mfile_id

      t.timestamps
    end
  end
end

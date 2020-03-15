class CreateFits < ActiveRecord::Migration[5.2]
  def change
    create_table :fits do |t|
      t.string :pattern
      t.integer :bookmark_id

      t.timestamps
    end
  end
end

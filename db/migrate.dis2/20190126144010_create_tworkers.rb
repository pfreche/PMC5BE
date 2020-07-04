class CreateTworkers < ActiveRecord::Migrations[5.2]
  def change
    create_table :tworkers do |t|
      t.string :name
      t.integer :fit_id
      t.string :tag
      t.string :attr
      t.string :pattern
      t.integer :action
      t.boolean :final

      t.timestamps
    end
  end
end

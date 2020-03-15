class AddTitleToMfile < ActiveRecord::Migration[5.2]
  def change
    add_column :mfiles, :title, :string
  end
end

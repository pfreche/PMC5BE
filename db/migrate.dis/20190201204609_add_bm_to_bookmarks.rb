class AddBmToBookmarks < ActiveRecord::Migration[5.2]
  def change
    add_column :bookmarks, :bookmark_id, :integer
  end
end

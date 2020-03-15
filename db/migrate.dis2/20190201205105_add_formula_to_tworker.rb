class AddFormulaToTworker < ActiveRecord::Migration[5.2]
  def change
    add_column :tworkers, :formular, :string
  end
end

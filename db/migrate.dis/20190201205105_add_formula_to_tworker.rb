class AddFormulaToTworker < ActiveRecord::Migrations[5.2]
  def change
    add_column :tworkers, :formular, :string
  end
end

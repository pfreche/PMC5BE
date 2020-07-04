class AddPropConfigToTworker < ActiveRecord::Migrations[5.2]
  def change
    add_column :tworkers, :prop_config, :string
  end
end

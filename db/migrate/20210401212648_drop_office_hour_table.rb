class DropOfficeHourTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :office_hours
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

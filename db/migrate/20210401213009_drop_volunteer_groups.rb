class DropVolunteerGroups < ActiveRecord::Migration[6.0]
  def up
    drop_table :volunteer_groups
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

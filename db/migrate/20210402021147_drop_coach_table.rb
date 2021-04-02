class DropCoachTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :coaches
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

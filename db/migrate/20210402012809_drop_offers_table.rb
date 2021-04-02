class DropOffersTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :offers
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

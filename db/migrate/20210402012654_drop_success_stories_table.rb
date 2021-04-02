class DropSuccessStoriesTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :success_stories
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

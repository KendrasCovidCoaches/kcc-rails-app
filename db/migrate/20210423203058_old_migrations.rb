class OldMigrations < ActiveRecord::Migration[6.0]
  REQUIRED_VERSION = 20210422234320
  def up
    if ActiveRecord::Migrator.current_version < REQUIRED_VERSION
      raise StandardError, "`rails db:schema:load` must be run prior to `rails db:migrate`"
    end
  end
end

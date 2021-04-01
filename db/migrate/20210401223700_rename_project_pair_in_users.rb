class RenameProjectPairInUsers < ActiveRecord::Migration[6.0]
  def change
    rename_column(:users, :pair_with_projects, :pair_with_appointments)
  end
end

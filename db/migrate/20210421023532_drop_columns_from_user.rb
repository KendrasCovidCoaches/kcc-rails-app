class DropColumnsFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :about
    remove_column :users, :location
    remove_column :users, :profile_links
    remove_column :users, :visibility
    remove_column :users, :name
    rename_column :users, :pair_with_appointments, :pair_with_requests
    remove_column :users, :deactivated
    remove_column :users, :newsletter_consent
    remove_column :users, :phone
    remove_column :users, :affiliation
    remove_column :users, :resume
    remove_column :users, :remote_location
  end
end

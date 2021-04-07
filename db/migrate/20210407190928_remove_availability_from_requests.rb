class RemoveAvailabilityFromRequests < ActiveRecord::Migration[6.0]
  def change
    remove_column :requests, :weekday_avail
    remove_column :requests, :weekday_times
    remove_column :requests, :weekend_avail
    remove_column :requests, :weekend_times
  end
end

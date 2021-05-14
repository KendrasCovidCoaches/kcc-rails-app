class RemoveCommStatusFromAppointments < ActiveRecord::Migration[6.0]
  def change
    remove_column :appointments, :communication_status
  end
end

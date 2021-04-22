class AddCommunicatedBooleanToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :communicated, :boolean, { null:false, default: false }
  end
end

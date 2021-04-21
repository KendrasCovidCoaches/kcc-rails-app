class DropTableAppointments < ActiveRecord::Migration[6.0]
  def change
    drop_table :appointments
  end
end

class AddAddressToAppointments < ActiveRecord::Migration[6.0]
  def change
    add_column :appointments, :address, :string
  end
end

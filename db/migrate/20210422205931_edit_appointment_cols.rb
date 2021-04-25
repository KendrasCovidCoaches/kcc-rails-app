class EditAppointmentCols < ActiveRecord::Migration[6.0]
  def change
    rename_column :appointments, :name, :patient_name
    add_column :appointments, :booked_by_name, :string
    add_column :appointments, :booked_by_email, :string
  end
end

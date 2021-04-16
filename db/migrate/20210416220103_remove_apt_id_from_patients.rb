class RemoveAptIdFromPatients < ActiveRecord::Migration[6.0]
  def change
    remove_column :patients, :appointment_id
  end
end

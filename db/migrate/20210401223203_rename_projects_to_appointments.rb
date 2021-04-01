class RenameProjectsToAppointments < ActiveRecord::Migration[6.0]
  def change
    rename_table('projects', 'appointments')
  end
end

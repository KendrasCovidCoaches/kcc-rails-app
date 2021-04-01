class RenameProjectColumnVolunteers < ActiveRecord::Migration[6.0]
  def change
    rename_column(:volunteers, :project_id, :appointment_id)
  end
end

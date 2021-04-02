class RenameVolunteersToPatientsAppts < ActiveRecord::Migration[6.0]
  def change
    rename_column(:appointments, :volunteer_location, :patient_location)
    rename_column(:appointments, :number_of_volunteers, :number_of_patients)
    rename_column(:appointments, :accepting_volunteers, :accepting_patients)
  end
end

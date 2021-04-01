class DataController < ApplicationController
  def appointments
    respond_with_csv(Appointment, ["id", "user_id", "name", 
    "description", "created_at", "updated_at", "location", 
    "highlight", "number_of_volunteers", "organization", 
    "level_of_urgency", "start_date", "end_date", 
    "compensation", "background_screening_required",
    "level_of_exposure", "visible", "was_helpful"])
  end

  def users
    respond_with_csv(User, ["id", 
    "created_at", "updated_at", "location", 
    "level_of_availability", "pair_with_appointments", "affiliation"])
  end

  def volunteers
    respond_with_csv(Volunteer, ["id", "user_id", "appointment_id",
  "created_at", "updated_at"])
  end

  private

  def respond_with_csv(model, fields)
    data = CSV.generate(headers: true) do |csv|
      csv << fields

      model.all.each do |e|
        csv << e.attributes
      end
    end

    respond_to do |format|
      format.csv { send_data data }
    end
  end
end

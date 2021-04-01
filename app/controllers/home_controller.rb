class HomeController < ApplicationController
  before_action :hydrate_appointment_categories
  before_action :hide_global_announcements
  before_action :set_bg_white

  def index
      @appointment_count = Rails.cache.fetch('appointment_count', expires_in: 1.day) do
        Appointment.count
      end
    @appointment_count_total = @appointment_count
    # Display the appointments in increments of 50
    @appointment_count = (@appointment_count / 50).floor * 50

    @patient_count = Rails.cache.fetch('patient_count', expires_in: 1.day) do
      User.count
    end

    @home_header = "#{HOME_HEADER}"
    @home_sub_header = "#{HOME_SUBHEADER}"
    @featured_appointments = Appointment.get_featured_appointments
  end
end

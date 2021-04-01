# Preview all emails at http://localhost:3000/rails/mailers/appointment_mailer
class AppointmentMailerPreview < ActionMailer::Preview
  def new_volunteer
    user = User.first
    appointment = Appointment.last

    AppointmentMailer.with(appointment: appointment, user: user, note: 'Note from volunteer').new_volunteer
  end

  # def volunter_outreach
  #   user = User.first
  #   AppointmentMailer.with(user: user).volunteer_outreach
  # end
end

class AppointmentMailer < ApplicationMailer
  def new_volunteer
    @appointment = params[:appointment]
    @user = params[:user]

    mail(to: "<#{@appointment.user.email}>", bcc: MAILER_BCC, subject: "You got a new volunteer for #{@appointment.name}!")
  end

  def new_appointment
    @appointment = params[:appointment]
    mail(to: "<#{@appointment.user.email}>", bcc: MAILER_BCC, subject: "You created a new opportunity: #{@appointment.name}!")
  end

  def cancel_volunteer
    @user = params[:user]
    @appointment = params[:appointment]
    mail(to: "<#{@user.email}>", subject: "[ResiTown Sacramento: noreply] Your Request To Volunteer Has Been Canceled")
  end

  # def volunteer_outreach
  #   @user = params[:user]
  #   mail(to: "<#{@user.email}>", reply_to: HWC_EMAIL, subject: "[ResiTown Sacramento - action required] Thank you and an update")
  # end
end

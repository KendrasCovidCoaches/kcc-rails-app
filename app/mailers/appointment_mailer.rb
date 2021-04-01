class AppointmentMailer < ApplicationMailer
  def new_patient
    @appointment = params[:appointment]
    @user = params[:user]

    mail(to: "<#{@appointment.user.email}>", bcc: MAILER_BCC, subject: "You got a new patient for #{@appointment.name}!")
  end

  def new_appointment
    @appointment = params[:appointment]
    mail(to: "<#{@appointment.user.email}>", bcc: MAILER_BCC, subject: "You created a new opportunity: #{@appointment.name}!")
  end

  def cancel_patient
    @user = params[:user]
    @appointment = params[:appointment]
    mail(to: "<#{@user.email}>", subject: "[KCC@noreply] Your Request Has Been Canceled")
  end

  # def patient_outreach
  #   @user = params[:user]
  #   mail(to: "<#{@user.email}>", reply_to: HWC_EMAIL, subject: "[ResiTown Sacramento - action required] Thank you and an update")
  # end
end

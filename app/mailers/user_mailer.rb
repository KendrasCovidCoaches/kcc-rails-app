class UserMailer < ApplicationMailer
    def welcome_email
      @user = params[:user]
      # @url  = 'change-to-correct-URL.com'
      mail(to: "<#{@user.email}>", subject: "[Kendra's Covid Coachesto: Sign Up Confirmed] Thank you for joining the KCC community!")
    end
  
  end
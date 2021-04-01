class AdminController < ApplicationController
  before_action :ensure_admin

  def index

  end

  # def edit_site

  # end

  def delete_user
    @user = User.find(params[:user_id])
    @user.destroy!

    flash[:notice] = 'User deleted'
    redirect_to patients_path
  end

  def toggle_highlight
    @appointment = Appointment.find(params[:appointment_id])
    @appointment.highlight = !@appointment.highlight
    @appointment.save

    flash[:notice] = @appointment.highlight? ? 'Appointment highlighted' : 'Removed highlight on appointment'
    redirect_to appointment_path(@appointment)
  end
end

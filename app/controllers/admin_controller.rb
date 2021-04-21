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
    @request = Request.find(params[:request_id])
    @request.highlight = !@request.highlight
    @request.save

    flash[:notice] = @request.highlight? ? 'Request highlighted' : 'Removed highlight on request'
    redirect_to request_path(@request)
  end
end

class ResourcesController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :set_resource, only: [ :show, :edit, :update, :destroy ]
  before_action :ensure_owner_or_admin, only: [ :edit, :update, :destroy ]
  before_action :hide_global_announcements
  before_action :set_bg_white, only: [ :index ]

  def index
    @resources = Resource.all.order('created_at DESC').all
  end

  def show
  end

  def new
    @resource = Resource.new
  end

  def edit
  end

  def create
    @resource = Resource.new(resource_params)

    @resource.user = current_user

    respond_to do |format|
      if @resource.save
        format.html { redirect_to @resource, notice: I18n.t('resource_was_successfully_created') }
        format.json { render :show, status: :created, location: @resource }
      else
        format.html { render :new }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @resource.update(resource_params)
        format.html { redirect_to @resource, notice: I18n.t('resource_was_successfully_updated') }
        format.json { render :show, status: :ok, location: @resource }
      else
        format.html { render :edit }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url, notice: I18n.t('resource_was_successfully_destroyed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.fetch(:resource, {}).permit(:name, :description, :limitations, :redemption, :location)
    end

    def ensure_owner_or_admin
      if current_user != @resource.user && !current_user.is_admin?
        flash[:error] = I18n.t('apologies_you_don_t_have_access_to_this')
        redirect_to resources_path
      end
    end
end
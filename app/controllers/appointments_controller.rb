class AppointmentsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :toggle_volunteer, :completed_volunteer, :volunteered, :own, :volunteers ]
  before_action :set_appointment, only: [ :show, :edit, :update, :destroy, :toggle_volunteer, :completed_volunteer, :volunteers ]
  before_action :ensure_owner_or_admin, only: [ :edit, :update, :destroy, :volunteers ]
  before_action :set_filters_open, only: :index
  before_action :set_appointments_query, only: :index
  before_action :hydrate_appointment_categories, only: :index
  before_action :ensure_no_legacy_filtering, only: :index
  before_action :set_bg_white, only: [:index, :own, :volunteered]

  def index
    params[:page] ||= 1
    @show_filters = true
    @show_search_bar = true
    @show_sorting_options = true
    @show_global_announcements = false
    @applied_filters = params.dup

    if request.path != appointments_path and params[:category_slug].present?
      @appointment_category = Settings.appointment_categories.find { |category| category.slug == params[:category_slug] }
      @appointment_location = Settings.appointment_locations.find { |location| location.slug == params[:category_slug] }
      #byebug
      raise ActionController::RoutingError, 'Not Found' if @appointment_category.blank? && @appointment_location.blank?

      if @appointment_category.present?
        @applied_filters[:appointment_types] = @appointment_category[:appointment_types]
        @featured_appointments = Rails.cache.read "appointment_category_#{@appointment_category[:name].downcase}_featured_appointments"
        @appointments = @appointments.tagged_with(params[:category_slug], any: true, on: :categories) if params[:category_slug].present?
        #byebug
      end

      if @appointment_location.present?
        @applied_filters[:appointment_types] = @appointment_location[:appointment_types]
        @featured_appointments = Rails.cache.read "appointment_category_#{@appointment_location[:name].downcase}_featured_appointments"
        @appointments = @appointments.tagged_with(params[:category_slug], any: true, on: :locations) if params[:category_slug].present?
        #byebug
      end
    
    else
      @featured_appointments = Appointment.get_featured_appointments
    end

    respond_to do |format|
      format.html do
        @appointments_header = I18n.t('appointments_looking_for_volunteers')
        @appointments_subheader = I18n.t('new_or_established_appointments_helping_with')
        @page_title = I18n.t('all_appointments')

        @appointments = @appointments.page(params[:page]).per(24)

        @index_from = (@appointments.prev_page || 0) * @appointments.limit_value + 1
        @index_to = [@index_from + @appointments.limit_value - 1, @appointments.total_count].min
        @total_count = @appointments.total_count
      end
      format.json do
        render json: @appointments
      end
    end
  end

  def volunteered
    params[:page] ||= 1

    @appointments = current_user.volunteered_appointments.page(params[:page]).per(25)
    @index_from = (@appointments.prev_page || 0) * @appointments.limit_value + 1
    @index_to = [@index_from + @appointments.limit_value - 1, @appointments.total_count].min

    @appointments_header = I18n.t('volunteered_appointments')
    @appointments_subheader = I18n.t('these_are_the_appointments_where_you_volunteered')
    @page_title = I18n.t('volunteered_appointments')
    render action: 'index'
  end

  def own
    params[:page] ||= 1

    @appointments = current_user.appointments.page(params[:page]).per(25)

    @index_from = (@appointments.prev_page || 0) * @appointments.limit_value + 1
    @index_to = [@index_from + @appointments.limit_value - 1, @appointments.total_count].min

    @appointments_header = I18n.t('own_appointments')
    @appointments_subheader = I18n.t('these_are_the_appointments_you_created')
    @page_title = I18n.t('own_appointments')
    render action: 'index'
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: @appointment }
    end
  end

  def volunteers
    respond_to do |format|
      format.csv { send_data @appointment.volunteered_users.to_csv, filename: "volunteers-#{Date.today}.csv" }
    end
  end

  def new
    @appointment = Appointment.new
    track_event 'Appointment creation started'
  end

  def create
    @appointment = current_user.appointments.new(appointment_params)
    @appointment.volunteer_location = @appointment.location_list[0]
    respond_to do |format|
      if @appointment.save
        track_event 'Appointment creation complete'
        AppointmentMailer.with(appointment: @appointment).new_appointment.deliver_now
        format.html { redirect_to @appointment, notice: I18n.t('appointment_was_successfully_created') }
        format.json { render :show, status: :created, location: @appointment }
      else
        format.html { render :new }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    updated = @appointment.update(appointment_params)

    respond_to do |format|
      if updated
        format.html { redirect_to @appointment, notice: I18n.t('appointment_was_successfully_updated') }
        format.json { render :show, status: :ok, location: @appointment }
      else
        format.html { render :edit }
        format.json { render json: @appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @appointment.destroy
    respond_to do |format|
      format.html { redirect_to appointments_url, notice: I18n.t('appointment_was_successfully_deleted') }
      format.json { head :no_content }
    end
  end

  def toggle_volunteer
    if @appointment.volunteered_users.include?(current_user)
      #byebug
      @appointment.volunteers.where(user: current_user).destroy_all
      flash[:notice] = I18n.t('we_ve_removed_you_from_the_list_of_volunteered_peo')
      AppointmentMailer.with(appointment: @appointment, user: current_user).cancel_volunteer.deliver_now
    else
      params[:volunteer_note] ||= ''

      Volunteer.create(user: current_user, appointment: @appointment, note: params[:volunteer_note])

      AppointmentMailer.with(appointment: @appointment, user: current_user, note: params[:volunteer_note]).new_volunteer.deliver_now

      flash[:notice] = I18n.t('thanks_for_volunteering_the_appointment_owners_will_be')
      track_event 'User volunteered'
    end

    redirect_to appointment_path(@appointment)
  end

  def completed_volunteer
    #byebug
    if @appointment.volunteered_users.include?(current_user)
      #byebug
      @appointment.volunteers.where(user: current_user).destroy_all
      flash[:notice] = I18n.t('completed')
      #AppointmentMailer.with(appointment: @appointment, user: current_user).cancel_volunteer.deliver_now
    end

    redirect_to volunteered_appointments_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_appointment
      @appointment = Appointment.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def appointment_params
      params.fetch(:appointment, {}).permit(:name, :organization, :organization_mission, :organization_registered, :level_of_urgency, :level_of_exposure, :description, :participants, :looking_for, :contact, :volunteer_location, :links, :start_date, :end_date, :end_date_recurring, :compensation, :background_screening_required, :progress, :docs_and_demo, :number_of_volunteers, :was_helpful, :exit_comments, :visible, :category_slug, :page, :skill_list => [], :completion_list => [], :category_list => [], :location_list => [], :appointment_type_list => [], :vol_list => [])
    end

    def ensure_owner_or_admin
      if !@appointment.can_edit?(current_user)
        flash[:error] = I18n.t('apologies_you_don_t_have_access_to_this')
        redirect_to appointments_path
      end
    end

    def set_appointments_query
      @applied_filters = {}

      @appointments = Appointment
      @appointments = @appointments.tagged_with(params[:skills], any: true, on: :skills) if params[:skills].present?
      @appointments = @appointments.tagged_with(params[:appointment_types], any: true, on: :appointment_types) if params[:appointment_types].present?
      @appointments = @appointments.tagged_with(params[:categories], any: true, on: :categories) if params[:categories].present?
      @appointments = @appointments.tagged_with(params[:locations], any: true, on: :locations) if params[:locations].present?
      @appointments = @appointments.where(accepting_volunteers: params[:accepting_volunteers] == '1') if params[:accepting_volunteers].present?
      @appointments = @appointments.where(highlight: true) if params[:highlight].present?
      @appointments = @appointments.where(target_country: params[:target_country]) if params[:target_country].present?
      @appointments = @appointments.where(status: params[:status]) if params[:status].present?

      if params[:query].present?
        @appointments = @appointments.search(params[:query]).left_joins(:volunteers).reorder(nil).group(:id)
      else
        @appointments = @appointments.left_joins(:volunteers).group(:id)
      end

      if params[:sort_by]
        @appointments = @appointments.order(get_order_param)
      else
        @appointments = @appointments.order('highlight DESC, COUNT(volunteers.id) DESC, created_at DESC')
      end

      if params[:appointment_types].present?
        @applied_filters[:appointment_types] = params[:appointment_types]
        @appointments = @appointments.tagged_with(params[:appointment_types]).left_joins(:volunteers).reorder(nil).group(:id)
      else
        @appointments = @appointments.left_joins(:volunteers).group(:id)
      end

      if params[:categories].present?
        @applied_filters[:categories] = params[:categories]
        @appointments = @appointments.tagged_with(params[:categories]).left_joins(:volunteers).reorder(nil).group(:id)
      else
        @appointments = @appointments.left_joins(:volunteers).group(:id)
      end

      if params[:locations].present?
        @applied_filters[:locations] = params[:locations]
        @appointments = @appointments.tagged_with(params[:locations]).left_joins(:volunteers).reorder(nil).group(:id)
      else
        @appointments = @appointments.left_joins(:volunteers).group(:id)
      end

      if params[:skills].present?
        @applied_filters[:skills] = params[:skills]
        @appointments = @appointments.tagged_with(params[:skills]).left_joins(:volunteers).reorder(nil).group(:id)
      else
        @appointments = @appointments.left_joins(:volunteers).group(:id)
      end

      @appointments = @appointments.includes(:appointment_types, :skills, :categories, :locations, :volunteers)
    end

    def ensure_no_legacy_filtering
      new_params = {}

      if params[:skills].present? and params[:skills].include? ','
        new_params[:skills] = params[:skills].split(',')
      end

      if params[:appointment_types].present? and params[:appointment_types].include? ','
        new_params[:appointment_types] = params[:appointment_types].split(',')
      end

      if params[:categories].present? and params[:categories].include? ','
        new_params[:categories] = params[:categories].split(',')
      end

      if params[:locations].present? and params[:locations].include? ','
        new_params[:locations] = params[:locations].split(',')
      end

      return redirect_to appointments_path(new_params) if new_params.present?
    end

    def get_order_param
      return 'created_at asc' if params[:sort_by] == 'earliest'
      return 'created_at desc' if params[:sort_by] == 'latest'
      return 'volunteers.count asc' if params[:sort_by] == 'volunteers_needed'
    end
end
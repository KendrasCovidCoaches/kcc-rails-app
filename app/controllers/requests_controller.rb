class RequestsController < ApplicationController
    before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy, :toggle_patient, :completed_patient, :requested, :own, :patients ]
    before_action :set_request, only: [ :show, :edit, :update, :destroy, :toggle_patient, :completed_patient, :patients ]
    before_action :ensure_owner_or_admin, only: [ :edit, :update, :destroy, :patients ]
    before_action :set_filters_open, only: :index
    before_action :set_requests_query, only: :index
    before_action :hydrate_appointment_categories, only: :index
    before_action :ensure_no_legacy_filtering, only: :index
    before_action :set_bg_white, only: [:index, :own, :requested]
  
    def index
      params[:page] ||= 1
      @show_filters = true
      @show_search_bar = true
      @show_sorting_options = true
      @show_global_announcements = false
      @applied_filters = params.dup
  
      if request.path != requests_path and params[:category_slug].present?
        @request_category = Settings.appointment_categories.find { |category| category.slug == params[:category_slug] }
        @request_location = Settings.appointment_locations.find { |location| location.slug == params[:category_slug] }
        #byebug
        raise ActionController::RoutingError, 'Not Found' if @request_category.blank? && @request_location.blank?
  
        if @request_category.present?
          @applied_filters[:request_types] = @request_category[:request_types]
          @featured_requests = Rails.cache.read "request_category_#{@request_category[:name].downcase}_featured_requests"
          @requests = @requests.tagged_with(params[:category_slug], any: true, on: :categories) if params[:category_slug].present?
          #byebug
        end
  
        if @request_location.present?
          @applied_filters[:request_types] = @request_location[:request_types]
          @featured_requests = Rails.cache.read "request_category_#{@request_location[:name].downcase}_featured_requests"
          @requests = @requests.tagged_with(params[:category_slug], any: true, on: :locations) if params[:category_slug].present?
          #byebug
        end
      
      else
        @featured_requests = Request.get_featured_requests
      end
  
      respond_to do |format|
        format.html do
          @requests_header = I18n.t('requests_looking_for_patients')
          @requests_subheader = I18n.t('new_or_established_requests_helping_with')
          @page_title = I18n.t('all_requests')
  
          @requests = @requests.page(params[:page]).per(24)
  
          @index_from = (@requests.prev_page || 0) * @requests.limit_value + 1
          @index_to = [@index_from + @requests.limit_value - 1, @requests.total_count].min
          @total_count = @requests.total_count
        end
        format.json do
          render json: @requests
        end
      end
    end
  
    def requested
      params[:page] ||= 1
  
      @requests = current_user.requested_requests.page(params[:page]).per(25)
      @index_from = (@requests.prev_page || 0) * @requests.limit_value + 1
      @index_to = [@index_from + @requests.limit_value - 1, @requests.total_count].min
  
      @requests_header = I18n.t('requested_requests')
      @requests_subheader = I18n.t('these_are_the_requests_where_you_requested')
      @page_title = I18n.t('requested_requests')
      render action: 'index'
    end
  
    def own
      params[:page] ||= 1
  
      @requests = current_user.requests.page(params[:page]).per(25)
  
      @index_from = (@requests.prev_page || 0) * @requests.limit_value + 1
      @index_to = [@index_from + @requests.limit_value - 1, @requests.total_count].min
  
      @requests_header = I18n.t('own_requests')
      @requests_subheader = I18n.t('these_are_the_requests_you_created')
      @page_title = I18n.t('own_requests')
      render action: 'index'
    end
  
    def show
      respond_to do |format|
        format.html
        format.json { render json: @request }
      end
    end
  
    def patients
      respond_to do |format|
        format.csv { send_data @request.requested_users.to_csv, filename: "patients-#{Date.today}.csv" }
      end
    end
  
    def new
      @request = Request.new
      track_event 'Request creation started'
    end
  
    def create
      @request = current_user.requests.new(request_params)
      # @request.weekday_avail = @request.weekday_list.join(".").to_s
      # @request.weekday_times = @request.weekday_time_list.join(".").to_s
      # @request.weekend_avail = @request.weekend_list.join(".").to_s
      # @request.weekend_times = @request.weekend_time_list.join(".").to_s
      respond_to do |format|
        if @request.save
          track_event 'Request creation complete'
          Patient.create(user_id: current_user.id, request_id: @request.id)
          byebug
          # RequestMailer.with(request: @request).new_request.deliver_now
          format.html { redirect_to @request, notice: I18n.t('request_was_successfully_created') }
          format.json { render :show, status: :created, location: @request }
        else
          format.html { render :new }
          format.json { render json: @request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def edit
    end
  
    def update
      updated = @request.update(request_params)
  
      respond_to do |format|
        if updated
          format.html { redirect_to @request, notice: I18n.t('request_was_successfully_updated') }
          format.json { render :show, status: :ok, location: @request }
        else
          format.html { render :edit }
          format.json { render json: @request.errors, status: :unprocessable_entity }
        end
      end
    end
  
    def destroy
      @request.destroy
      respond_to do |format|
        format.html { redirect_to requests_url, notice: I18n.t('request_was_successfully_deleted') }
        format.json { head :no_content }
      end
    end
  
    def toggle_patient
      if @request.requested_users.include?(current_user)
        #byebug
        @request.patients.where(user: current_user).destroy_all
        flash[:notice] = I18n.t('we_ve_removed_you_from_the_list_of_requested_peo')
        # RequestMailer.with(request: @request, user: current_user).cancel_patient.deliver_now
      else
        params[:patient_note] ||= ''
  
        Patient.create(user: current_user, request: @request, note: params[:patient_note])
  
        # RequestMailer.with(request: @request, user: current_user, note: params[:patient_note]).new_patient.deliver_now
  
        flash[:notice] = I18n.t('thanks_for_requesting_the_coaches_will_be')
        track_event 'User requested'
      end
  
      redirect_to request_path(@request)
    end
  
    def completed_patient
      #byebug
      if @request.requested_users.include?(current_user)
        #byebug
        @request.patients.where(user: current_user).destroy_all
        flash[:notice] = I18n.t('completed')
        #RequestMailer.with(request: @request, user: current_user).cancel_patient.deliver_now
      end
  
      redirect_to requested_requests_path
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_request
        @request = Request.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def request_params
        params.fetch(:request, {}).permit(:user_id, :patient_email, :f_name, :l_name, :birth_date, :phone, :address, :highlight, :city, :state, 
        :zip, :sex, :pref_language, :self_book, :closest_city, :travel_radius, :weekday_avail, :weekday_times, :weekend_avail, :weekend_times, 
        :eligibility_group, :critical_to_book_with, :book_with_full_name, :book_with_email, :book_with_phone, :open_to_same_day, :notes, :requested_by_email,
        :requested_by_name, :over_50, :weekday_list => [], :weekend_list => [], :weekday_time_list => [], :weekend_time_list => [])
      end
  
      def ensure_owner_or_admin
        if !@request.can_edit?(current_user)
          flash[:error] = I18n.t('apologies_you_don_t_have_access_to_this')
          redirect_to requests_path
        end
      end
  
      def set_requests_query
        @applied_filters = {}
  
        @requests = Request
        @requests = @requests.tagged_with(params[:skills], any: true, on: :skills) if params[:skills].present?
        @requests = @requests.tagged_with(params[:request_types], any: true, on: :request_types) if params[:request_types].present?
        @requests = @requests.tagged_with(params[:categories], any: true, on: :categories) if params[:categories].present?
        @requests = @requests.tagged_with(params[:locations], any: true, on: :locations) if params[:locations].present?
        @requests = @requests.where(accepting_patients: params[:accepting_patients] == '1') if params[:accepting_patients].present?
        @requests = @requests.where(highlight: true) if params[:highlight].present?
        @requests = @requests.where(target_country: params[:target_country]) if params[:target_country].present?
        @requests = @requests.where(status: params[:status]) if params[:status].present?
  
        if params[:query].present?
          @requests = @requests.search(params[:query]).left_joins(:patients).reorder(nil).group(:id)
        else
          @requests = @requests.left_joins(:patients).group(:id)
        end
  
        if params[:sort_by]
          @requests = @requests.order(get_order_param)
        else
          @requests = @requests.order('highlight DESC, COUNT(patients.id) DESC, created_at DESC')
        end
  
        if params[:request_types].present?
          @applied_filters[:request_types] = params[:request_types]
          @requests = @requests.tagged_with(params[:request_types]).left_joins(:patients).reorder(nil).group(:id)
        else
          @requests = @requests.left_joins(:patients).group(:id)
        end
  
        if params[:categories].present?
          @applied_filters[:categories] = params[:categories]
          @requests = @requests.tagged_with(params[:categories]).left_joins(:patients).reorder(nil).group(:id)
        else
          @requests = @requests.left_joins(:patients).group(:id)
        end
  
        if params[:locations].present?
          @applied_filters[:locations] = params[:locations]
          @requests = @requests.tagged_with(params[:locations]).left_joins(:patients).reorder(nil).group(:id)
        else
          @requests = @requests.left_joins(:patients).group(:id)
        end
  
        if params[:skills].present?
          @applied_filters[:skills] = params[:skills]
          @requests = @requests.tagged_with(params[:skills]).left_joins(:patients).reorder(nil).group(:id)
        else
          @requests = @requests.left_joins(:patients).group(:id)
        end
  
        @requests = @requests.includes(:request_types, :skills, :categories, :locations, :patients)
      end
  
      def ensure_no_legacy_filtering
        new_params = {}
  
        if params[:skills].present? and params[:skills].include? ','
          new_params[:skills] = params[:skills].split(',')
        end
  
        if params[:request_types].present? and params[:request_types].include? ','
          new_params[:request_types] = params[:request_types].split(',')
        end
  
        if params[:categories].present? and params[:categories].include? ','
          new_params[:categories] = params[:categories].split(',')
        end
  
        if params[:locations].present? and params[:locations].include? ','
          new_params[:locations] = params[:locations].split(',')
        end
  
        return redirect_to requests_path(new_params) if new_params.present?
      end
  
      def get_order_param
        return 'created_at asc' if params[:sort_by] == 'earliest'
        return 'created_at desc' if params[:sort_by] == 'latest'
        return 'patients.count asc' if params[:sort_by] == 'patients_needed'
      end
end
  
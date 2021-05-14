class Request < ApplicationRecord
    include HasCoverPhoto
    include PgSearch::Model
  
    belongs_to :user
    has_many :appointments, dependent: :destroy
  
    validates :f_name, presence: true
    validates :l_name, presence: true
    # validates :short_description, length: { maximum: 129 }
    # validate :must_have_one_skill, on: :create
    # validate :date_order, on: :create
  
    has_many :patients, dependent: :destroy
    has_many :requested_users, through: :patients, source: :user, dependent: :destroy
  
    acts_as_taggable_on :weekdays
    acts_as_taggable_on :weekends
    acts_as_taggable_on :request_types
    acts_as_taggable_on :locations
    acts_as_taggable_on :weekday_times
    acts_as_taggable_on :weekend_times
    acts_as_taggable_on :skills  
    acts_as_taggable_on :categories  

  
    pg_search_scope :search, against: %i(name description participants looking_for patient_location target_country target_location highlight)
  
    after_save do
      # expire homepage caches if they contain this request
      Settings.request_categories.each do |category|
        cache_key = "request_category_#{category[:name].downcase}_featured_requests"
        featured_requests = Rails.cache.read cache_key
  
        next if featured_requests.blank?
  
        Rails.cache.delete(cache_key) if featured_requests.map(&:id).include? self.id
      end
    end
  
    # validates :status, inclusion: { in: Settings.request_statuses }
  
    # before_validation :default_values
  
    # def default_values
    #   self.status = Settings.request_statuses.first if self.status.blank?
    # end
  
    def to_param
      [id, f_name.parameterize, l_name.parameterize].join('-')
    end
  
    def can_edit?(edit_user)
      edit_user && (self.user == edit_user || edit_user.is_coach?)
    end
  
    def patient_emails
      self.requested_users.collect { |u| u.email }
    end
  
    def requested_users_count
      requested_users.count
    end
  
    def serializable_hash(options = {})
      super(
        only: [
          :id,
          :name,
          :description,
          :participants,
          :goal,
          :looking_for,
          :patient_location,
          :target_country,
          :target_location,
          :contact,
          :highlight,
          :progress,
          :docs_and_demo,
          :number_of_patients,
          :accepting_patients,
          :created_at,
          :updated_at,
          :status,
          :short_description
        ],
        methods: [:to_param, :requested_users_count, :request_type_list, :location_list, :category_list, :skill_list]
      )
    end
  
    def must_have_one_skill
      errors.add(:base, 'You must select at least one skill') if self.skill_list.all?{|skill| skill.blank? }    
    end
  
    def date_order
      if self.end_date_recurring != true
        if self.end_date != ''
          errors.add(:base, 'End date must be after start date') if Date.parse(self.start_date) > Date.parse(self.end_date)
        elsif self.end_date == ''
          errors.add(:base, 'You must provide an end date or select "Recurring"')
        end 
      end
    end
  
    def category
      request_categories = {}
      begin
        Settings.request_categories.each do |category|
          intersection = self.request_type_list.to_a & category['request_types'].to_a
          request_categories[category.name] = intersection.count
        end
  
        present_category = request_categories.sort_by { |k, v| v }.reverse.first.first
      end
  
      present_category
    end
  
    def cover_photo(category_override = nil)
      Rails.cache.fetch(cdn_image_cache_key, expires_in: 1.month) do
  
        if self.image.present?
          cdn_variant(resize_to_limit: [600, 600])
        else
          # FIXME use slug of category instead? and fallback if this is missing
          filename = category_override.blank? ? self.category.downcase.gsub(' ', '-') : category_override.downcase
  
          # There is no `image_pack_path` -- see https://github.com/rails/webpacker/issues/2562
          ActionController::Base.helpers.asset_pack_path "media/images/#{filename}-default.png"
        end
      end
    end
  
    def self.get_featured_requests
      requests_count = Settings.homepage_featured_requests_count
      Request.where(highlight: true).includes(:request_types, :categories, :locations, :skills, :patients).limit(requests_count).order('RANDOM()')
    end
end
  
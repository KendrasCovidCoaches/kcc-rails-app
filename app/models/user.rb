require 'csv'
require 'gibbon'
require 'net/https'
require 'json'

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable #, :confirmable

  include PgSearch::Model

  has_many :requests #, dependent: :destroy
  has_many :appointments, through: :requests
  has_many :patients, dependent: :destroy
  has_many :requested_appointments, through: :patients, source: :request, dependent: :destroy

  acts_as_taggable_on :skills

  pg_search_scope :search, against: %i(name email about location level_of_availability)

  def requested_for_appointment?(request)
    self.requested_appointments.where(id: request.id).exists?
  end

  def has_correct_skills?(request)
    request_skills = request.skills.map(&:name)
    return true if request_skills.include?('Anything')
    (self.skills.map(&:name) & request.skills.map(&:name)).present?
  end

  def is_visible_to_user?(user_trying_view)
    return true if self.visibility == true
    return false if user_trying_view.blank?
    return true if user_trying_view.is_coach?
    return true if user_trying_view == self

    # Check if this user requested for any appointment by user_trying_view.
    self.requested_appointments.where(user_id: user_trying_view.id).exists?
  end

  def is_coach?
    COACHES.include?(self.email)
  end

  def is_patient?
    !COACHES.include?(self.email)
  end

  def to_param
    [id, email.parameterize].join('-')
  end

  def self.to_csv
    attributes = %w{email about profile_links location level_of_availability}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  def active_for_authentication?
    super
  end

# this function uses Gibbon and Mailchimp API to subscribe/unsubscribe users
  def subscribe_to_mailchimp(action = true)
    if Rails.env.production?
      gibbon = Gibbon::Request.new
      gibbon.timeout = 15
      list_id = Settings.list_id

      response = gibbon.lists(list_id).members(Digest::MD5.hexdigest(self.email)).upsert(body: {
          email_address: self.email,
          status: action ? "subscribed" : "unsubscribed",
      })
      response
    end
  end

  

# this function is used with before_create
  

# this function checks if this user has completed Blank Slate training
  # def finished_training?
  #   uri = URI.parse(BLANK_SLATE_TRAINING_STATUS_URL)
  #   request = Net::HTTP::Post.new(uri)
  #   request.basic_auth(BLANK_SLATE_USERNAME, BLANK_SLATE_PASSWORD)
  #   request.content_type = "application/json"
  #   request.body = JSON.dump({
  #                                "email" => self.email
  #                            })

  #   req_options = {
  #       use_ssl: uri.scheme == "https",
  #   }

  #   response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  #     http.request(request)
  #   end

  #   if response.code == "200"
  #     result = JSON.parse(response.body)
  #     result['finishedAllCards']
  #   else
  #     false
  #   end
  # end

  def age_consent?
    return self.age_consent
  end

end


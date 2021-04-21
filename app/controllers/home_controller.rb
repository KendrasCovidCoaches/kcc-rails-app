class HomeController < ApplicationController
  before_action :hydrate_request_categories
  before_action :hide_global_announcements
  before_action :set_bg_white

  def index
      @request_count = Rails.cache.fetch('request_count', expires_in: 1.day) do
        Request.count
      end
    @request_count_total = @request_count
    # Display the requests in increments of 50
    @request_count = (@request_count / 50).floor * 50

    @patient_count = Rails.cache.fetch('patient_count', expires_in: 1.day) do
      User.count
    end

    @home_header = "#{HOME_HEADER}"
    @home_sub_header = "#{HOME_SUBHEADER}"
    @featured_requests = Request.get_featured_requests
  end
end

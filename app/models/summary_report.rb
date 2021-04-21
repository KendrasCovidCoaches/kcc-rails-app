class SummaryReport
  def initialize()

    #create end of month date starting from the beginning of the request to doday
    cutoff = Date.new(2020,3,31)
    @end_of_month_dates = []

    while cutoff < Date.today
      @end_of_month_dates << cutoff

      cutoff = (cutoff + 1.day).end_of_month
    end
    @end_of_month_dates << Date.today

    #create total count
    @user_count = User.all.count
    @requested_user_count = User.where("pair_with_requests = ?","True").count
    @new_user_count = User.where("created_at >= ?", Date.today - 7).count
    @request_count = Request.all.count
    @requested_request_count = Patient.count('DISTINCT request_id')
    @new_request_count = Request.where("created_at >= ?", Date.today - 7).count

    #create input arrays for the user and request table, 
    #counts the total for each end of month
 
    @user_table = @end_of_month_dates.map { |date|
      [date, User.where("created_at <= ?", date).count,
      User.where("created_at <= ? and pair_with_requests = ? ", date, "True").count]
    }

    @request_table = @end_of_month_dates.map { |date|
      [date, Request.where("created_at <= ?", date).count,
      Patient.where("created_at <= ?", date).count('DISTINCT request_id')]
    }

    #create input for graphs, total for each month
    @user_count_per_month = @end_of_month_dates.map { |date|
      bom = date.beginning_of_month
      eom = date.end_of_month
      User.where("created_at >= ? and created_at <= ?", bom, eom).count
    }

    @requested_user_count_per_month = @end_of_month_dates.map { |date|
      bom = date.beginning_of_month
      eom = date.end_of_month
      User.where("created_at >= ? and created_at <= ? and pair_with_requests = ? ", bom, eom, "True").count
    }
    @request_count_per_month = @end_of_month_dates.map { |date|
      bom = date.beginning_of_month
      eom = date.end_of_month
      Request.where("created_at >= ? and created_at <= ?", bom, eom).count
    }
    @requested_request_count_per_month = @end_of_month_dates.map { |date|
      bom = date.beginning_of_month
      eom = date.end_of_month
      Patient.where("created_at >= ? and created_at <= ?", bom, eom).count('DISTINCT request_id')
    }

    @month_labels = @end_of_month_dates.map { |e| e.strftime("%B") }

  end

  attr_reader :user_count, :requested_user_count, :new_user_count, 
    :request_count, :requested_request_count, :new_request_count,
    :user_table, :request_table, 
    :user_count_per_month, :requested_user_count_per_month, 
    :request_count_per_month, :requested_request_count_per_month,
    :month_labels


end
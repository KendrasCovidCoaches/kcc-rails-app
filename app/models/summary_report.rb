class SummaryReport
  def initialize()

    #create end of month date starting from the beginning of the appointment to doday
    cutoff = Date.new(2020,3,31)
    @end_of_month_dates = []

    while cutoff < Date.today
      @end_of_month_dates << cutoff

      cutoff = (cutoff + 1.day).end_of_month
    end
    @end_of_month_dates << Date.today

    #create total count
    @user_count = User.all.count
    @requested_user_count = User.where("pair_with_appointments = ?","True").count
    @new_user_count = User.where("created_at >= ?", Date.today - 7).count
    @appointment_count = Appointment.all.count
    @requested_appointment_count = Volunteer.count('DISTINCT appointment_id')
    @new_appointment_count = Appointment.where("created_at >= ?", Date.today - 7).count

    #create input arrays for the user and appointment table, 
    #counts the total for each end of month
 
    @user_table = @end_of_month_dates.map { |date|
      [date, User.where("created_at <= ?", date).count,
      User.where("created_at <= ? and pair_with_appointments = ? ", date, "True").count]
    }

    @appointment_table = @end_of_month_dates.map { |date|
      [date, Appointment.where("created_at <= ?", date).count,
      Volunteer.where("created_at <= ?", date).count('DISTINCT appointment_id')]
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
      User.where("created_at >= ? and created_at <= ? and pair_with_appointments = ? ", bom, eom, "True").count
    }
    @appointment_count_per_month = @end_of_month_dates.map { |date|
      bom = date.beginning_of_month
      eom = date.end_of_month
      Appointment.where("created_at >= ? and created_at <= ?", bom, eom).count
    }
    @requested_appointment_count_per_month = @end_of_month_dates.map { |date|
      bom = date.beginning_of_month
      eom = date.end_of_month
      Volunteer.where("created_at >= ? and created_at <= ?", bom, eom).count('DISTINCT appointment_id')
    }

    @month_labels = @end_of_month_dates.map { |e| e.strftime("%B") }

  end

  attr_reader :user_count, :requested_user_count, :new_user_count, 
    :appointment_count, :requested_appointment_count, :new_appointment_count,
    :user_table, :appointment_table, 
    :user_count_per_month, :requested_user_count_per_month, 
    :appointment_count_per_month, :requested_appointment_count_per_month,
    :month_labels


end
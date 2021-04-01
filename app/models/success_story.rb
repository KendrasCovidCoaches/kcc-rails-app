class SuccessStory < ApplicationRecord
  include HasCoverPhoto

  def to_param
    [id, title.parameterize].join('-')
  end

  def appointments
    return if appointment_ids.blank?

    begin
      Appointment.where id: appointment_ids.split(',').map(&:strip)
    end
  end
end

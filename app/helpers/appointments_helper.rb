module AppointmentsHelper
  def appointment_row_class(appointment)
    if appointment.highlight
      'border-2 border-orange-300 bg-orange-100'
    else
      'hover:bg-gray-50 focus:outline-none focus:bg-gray-50'
    end
  end

  def is_appointments_path
    request.path == appointments_path or request.path.include?('/appointments/p') or Settings.appointment_categories.map(&:slug).include?(params[:category_slug]) or Settings.appointment_locations.map(&:slug).include?(params[:category_slug])
  end

  def format_country(country)
    return country if country == '' || country == 'Global'

    begin
      IsoCountryCodes.find(country).name
    rescue
      # Fallback to raw value
      country
    end
  end

  def appointment_panel_item(title: '', &block)
    render layout: 'partials/appointment-panel-item', locals: {title: title} do
      capture(&block)
    end
  end
end

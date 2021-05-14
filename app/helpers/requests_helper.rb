module RequestsHelper
  def request_row_class(request)
    if request.highlight
      'border-2 border-orange-300 bg-orange-100'
    else
      'hover:bg-gray-50 focus:outline-none focus:bg-gray-50'
    end
  end

  # def is_requests_path
  #   request.path == requests_path or request.path.include?('/requests/p') or Settings.request_categories.map(&:slug).include?(params[:category_slug]) or Settings.request_locations.map(&:slug).include?(params[:category_slug])
  # end

  def format_country(country)
    return country if country == '' || country == 'Global'

    begin
      IsoCountryCodes.find(country).name
    rescue
      # Fallback to raw value
      country
    end
  end

  def request_panel_item(title: '', &block)
    render layout: 'partials/request-panel-item', locals: {title: title} do
      capture(&block)
    end
  end
end

class WxController < ApplicationController
  def index
  end

  def query
    service_method = (params[:type] == 'forecast' ? :get_forecast : :get_current_weather)

    @weather_data = WeatherApi.public_send(service_method, params[:location])

    respond_to do |format|
      format.html     # Not sure if I want this
      format.turbo_stream
    end

  rescue ArgumentError => e
    respond_to do |format|
      format.html { render plain: e.message, status: :bad_request }
      format.turbo_stream { render turbo_stream: turbo_stream.replace(
        'wx_result', plain: e.message) }
    end
  end
end

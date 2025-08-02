class WxController < ApplicationController
  def index
  end

  def query
    service_method = (params[:type] == "forecast" ? :get_forecast : :get_current_weather)

    @weather_data = WeatherApi.public_send(service_method, params[:location])

    respond_to do |format|
      format.turbo_stream
    end

  rescue ArgumentError => e
    @weather_data = { error: e.message }
    respond_to do |format|
      format.turbo_stream
    end
  end
end

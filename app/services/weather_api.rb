class WeatherApi
  # This service actually does the interaction between the Rails app and
  # weatherapi.com.
  #
  # Note that this service requires an API key, which must be exported
  # by the WEATHER_API_KEY environment variable.
  #
  # See also config/initializers/weather_api.rb

  def self.get_current_weather(location)
    raise ArgumentError, "No location given" if location.blank?

    location_key = make_location_key(location)

    is_cached = true
    observation = Rails.cache.fetch("weather/current/#{location_key}", expires_in: 30.minutes) do
      is_cached = false
      response = HTTParty.get("#{WEATHER_API_BASE_URL}/current.json", query: {
        q: location,
        key: WEATHER_API_KEY
      })
      JSON.parse(response.body)
    end

    { data: observation, cached: is_cached }
  end

  def self.get_forecast(location)
    raise ArgumentError, "No location given" if location.blank?

    location_key = make_location_key(location)

    is_cached = true
    forecast = Rails.cache.fetch("weather/forecast/#{location_key}", expires_in: 30.minutes) do
      is_cached = false
      response = HTTParty.get("#{WEATHER_API_BASE_URL}/forecast.json", query: {
        q: location,
        key: WEATHER_API_KEY
      })
      JSON.parse(response.body)
    end

    { data: forecast, cached: is_cached }
  end

  private

  # Constructs the key that will be used for caching results.
  #
  # NOTE: this will not be able to distinguish between different *forms*
  # of input. If you were to query for "Toronto, Ontario", "Toronto, Canada",
  # "CYYZ", and lat/long, these would each result in different keys. This could
  # possibly be optimized in the future though.
  def self.make_location_key(location)
    location.split(/[,\s+]/)
            .map(&:titleize)
            .join
  end
end

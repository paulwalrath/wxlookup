WEATHER_API_BASE_URL = ENV.fetch("WEATHER_API_BASE_URL", "https://api.weatherapi.com/v1").freeze
WEATHER_API_KEY = Rails.application.credentials.weather_api_key
WEATHER_CACHE_TIMEOUT = 30.minutes

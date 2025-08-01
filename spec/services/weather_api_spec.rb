require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherApi do
  let(:api_key) { "super-secret" }
  let(:current_wx_observation) do
    json_file = Rails.root.join('spec/fixtures/weather_api/cykf_current.json')
    JSON.parse(File.read(json_file))
  end

  # We want to cache results here, so we can test cache logic
  around do |rspec_test|
    original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    rspec_test.run
  ensure
    Rails.cache = original_cache
  end

  before do
    stub_const('WEATHER_API_KEY', api_key)
  end

  describe ".get_current_weather" do
    before do
      stub_request(:get, "#{WEATHER_API_BASE_URL}/current.json")
        .with(query: hash_including(q: anything, key: api_key))
        .to_return_json(status: 200, body: current_wx_observation)
    end

    context "when given a valid location" do
      it "queries Weather API for current observation" do
        result = described_class.get_current_weather("Kitchener, Ontario, Canada")
        expect(result).to eq({
          data: current_wx_observation,
          cached: false
        })
      end

      it "caches the result" do
        # First call to API (gets cached)
        result1 = described_class.get_current_weather("Vancouver Canada")
        expect(result1[:cached]).to eq(false)

        # Subsequent call (retrieved from cache)
        result2 = described_class.get_current_weather("Vancouver Canada")
        expect(result2[:cached]).to eq(true)

        expect(WebMock).to have_requested(:get, /current\.json/).once
      end
    end
  end
end

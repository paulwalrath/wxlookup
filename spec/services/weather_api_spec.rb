require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherApi do
  let(:cache) { Rails.cache }
  let(:api_key) { "super-secret" }
  let(:current_wx_observation) do
    json_file = Rails.root.join('spec/fixtures/weather_api/cykf_current.json')
    JSON.parse(File.read(json_file))
  end

  before do
    cache.clear
    ENV['WEATHER_API_KEY'] = api_key
    stub_request(:get, "#{WEATHER_API_BASE_URL}/current.json")
      .to_return_json(status: 200, body: current_wx_observation)
  end

  describe ".get_current_weather" do
    context "when given a valid location" do
      it "queries Weather API for current observation" do
        result = described_class.get_current_weather("Kitchener, Ontario, Canada")
        expect(result).to eq({
          data: current_wx_observation,
          cached: false
        })
      end
    end
  end
end

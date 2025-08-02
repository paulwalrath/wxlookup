require 'rails_helper'
require 'webmock/rspec'

RSpec.describe "WxController", type: :request do
  # NOTE: for simplicity, we'll use a single city's weather results
  # for all mocked queries.
  let(:current_wx_observation) do
    json_file = Rails.root.join('spec/fixtures/weather_api/cykf_current.json')
    JSON.parse(File.read(json_file))
  end
  let(:wx_forecast) do
    json_file = Rails.root.join('spec/fixtures/weather_api/cyvr_forecast.json')
    JSON.parse(File.read(json_file))
  end

  before { stub_const('WEATHER_API_KEY', 'super-secret-key!!') }

  describe "GET /index" do
    it "returns the home page" do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to match(/Weather Lookup/)
    end
  end

  describe "POST /query (via Turbo)" do
    let(:turbo_headers) { { "Accept" => "text/vnd.turbo-stream.html" } }

    context "when getting current weather observations" do
      before do
        stub_request(:get, "#{WEATHER_API_BASE_URL}/current.json")
          .with(query: hash_including(q: anything, key: WEATHER_API_KEY))
          .to_return_json(status: 200, body: current_wx_observation)
      end

      context "given a location and query-type" do
        it "displays the results below the query box" do
          post wx_query_path,
            params: { type: :current, location: "Vancouver Canada" },
            headers: turbo_headers
          expect(response).to have_http_status(:success)
          expect(response.body).to include('turbo-stream action="update"')
        end
      end
    end

    context "when getting a forecast" do
      before do
        stub_request(:get, "#{WEATHER_API_BASE_URL}/forecast.json")
          .with(query: hash_including(q: anything, key: WEATHER_API_KEY))
          .to_return_json(status: 200, body: wx_forecast)
      end

      context "given a location and query-type" do
        it "displays the results below the query box" do
          post wx_query_path,
            params: { type: :forecast, location: "Vancouver Canada" },
            headers: turbo_headers
          expect(response).to have_http_status(:success)
          expect(response.body).to include('turbo-stream action="update"')
        end
      end
    end

    context "without a required location" do
      it "fails with an error" do
        post "/wx/query", xhr: true  # all required parameters missing
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to match(/No location given/)
      end
    end
  end
end

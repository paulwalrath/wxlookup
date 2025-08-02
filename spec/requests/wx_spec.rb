require 'rails_helper'

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

  before do
    stub_const('WEATHER_API_KEY', 'super-secret-key!!')
    stub_request(:get, "#{WEATHER_API_BASE_URL}/current.json")
      .with(query: hash_including(q: anything, key: WEATHER_API_KEY))
      .to_return_json(status: 200, body: current_wx_observation)
  end

  describe "GET /index" do
    it "returns the home page" do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to match(/Weather Lookup/)
    end
  end

  describe "POST /query (via Turbo)" do
    context "when getting current weather observations" do
      context "given a location and query-type" do
        it "displays the results below the query box" do
          post wx_query_path, params: { type: :current, location: "Vancouver Canada"}
          expect(response).to have_http_status(:success)
          expect(response.body).to include('turbo-stream action="replace"')
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

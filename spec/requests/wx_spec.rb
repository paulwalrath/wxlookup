require 'rails_helper'

RSpec.describe "WxController", type: :request do
  describe "GET /index" do
    it "returns the home page" do
      get "/wx/index"
      expect(response).to have_http_status(:success)
      expect(response.body).to match(/Weather Lookup/)
    end
  end

  describe "GET /query" do
    context "when given a location and query-type" do
      pending "todo"
    end

    context "without a required location" do
      it "fails with an error" do
        get "/wx/query"  # all required parameters missing
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to match(/No location given/)
      end
    end
  end

end

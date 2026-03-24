require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  describe "GET /dashboard" do
    it "returns http success" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end

    it "shows stats with completed sessions" do
      create(:practice_session, :completed)
      get dashboard_path
      expect(response).to have_http_status(:success)
    end
  end
end

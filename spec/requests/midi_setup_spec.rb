require "rails_helper"

RSpec.describe "MidiSetup", type: :request do
  describe "GET /midi_setup" do
    it "returns http success" do
      get midi_setup_path
      expect(response).to have_http_status(:success)
    end
  end
end

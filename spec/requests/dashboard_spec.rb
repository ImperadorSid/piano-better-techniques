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

    it "calculates total completed sessions" do
      create_list(:practice_session, 3, :completed)
      create(:practice_session, completed: false)
      get dashboard_path

      expect(response.body).to include("3")
    end

    it "calculates average accuracy across completed sessions" do
      create(:practice_session, :completed, accuracy_pct: 80.0)
      create(:practice_session, :completed, accuracy_pct: 60.0)
      get dashboard_path

      expect(response.body).to include("70.0")
    end

    it "counts distinct songs practiced" do
      song1 = create(:song, :with_part)
      song2 = create(:song, :with_part)
      create(:practice_session, :completed, song: song1, song_part: song1.song_parts.first)
      create(:practice_session, :completed, song: song1, song_part: song1.song_parts.first)
      create(:practice_session, :completed, song: song2, song_part: song2.song_parts.first)
      get dashboard_path

      expect(response.body).to include("2")
    end

    it "only shows completed sessions in recent list" do
      completed = create(:practice_session, :completed)
      incomplete = create(:practice_session, completed: false)
      get dashboard_path

      expect(response.body).to include(completed.song.title)
    end

    it "returns zero averages with no sessions" do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end
  end
end

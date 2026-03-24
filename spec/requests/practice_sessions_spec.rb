require "rails_helper"

RSpec.describe "PracticeSessions", type: :request do
  let!(:song_part) { create(:song_part) }
  let!(:session)   { create(:practice_session, song: song_part.song, song_part: song_part) }

  describe "GET /practice_sessions" do
    it "returns http success" do
      get practice_sessions_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /song_parts/:id/practice_sessions/:id" do
    it "returns http success" do
      get song_part_practice_session_path(song_part, session)
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /song_parts/:id/practice_sessions" do
    it "creates a new session and redirects" do
      expect {
        post song_part_practice_sessions_path(song_part)
      }.to change(PracticeSession, :count).by(1)
      expect(response).to redirect_to(song_part_practice_session_path(song_part, PracticeSession.last))
    end
  end

  describe "PATCH /practice_sessions/:id/complete" do
    it "marks the session as complete" do
      patch complete_practice_session_path(session), params: { notes_reached: 3 }
      expect(session.reload.completed).to be true
    end
  end
end

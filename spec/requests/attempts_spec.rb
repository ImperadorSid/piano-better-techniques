require "rails_helper"

RSpec.describe "Attempts", type: :request do
  let!(:song_part) { create(:song_part) }
  let!(:session)   { create(:practice_session, song: song_part.song, song_part: song_part) }

  describe "POST /song_parts/:id/practice_sessions/:id/attempts" do
    let(:valid_params) do
      {
        attempt: {
          note_position: 0,
          expected_midi: 60,
          played_midi: 60,
          correct: true,
          response_ms: 350
        }
      }
    end

    it "creates a session attempt and returns 201" do
      expect {
        post song_part_practice_session_attempts_path(song_part, session),
             params: valid_params.to_json,
             headers: { "Content-Type" => "application/json" }
      }.to change(SessionAttempt, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it "increments correct_notes on correct attempt" do
      post song_part_practice_session_attempts_path(song_part, session),
           params: valid_params.to_json,
           headers: { "Content-Type" => "application/json" }
      expect(session.reload.correct_notes).to eq(1)
    end

    it "increments incorrect_notes on wrong attempt" do
      wrong_params = valid_params.deep_merge(attempt: { played_midi: 62, correct: false })
      post song_part_practice_session_attempts_path(song_part, session),
           params: wrong_params.to_json,
           headers: { "Content-Type" => "application/json" }
      expect(session.reload.incorrect_notes).to eq(1)
    end

    it "stores velocity data when provided" do
      velocity_params = {
        attempt: {
          note_position: 0,
          expected_midi: 60,
          played_midi: 60,
          correct: true,
          response_ms: 350,
          played_velocity: 90,
          expected_velocity: 75
        }
      }
      post song_part_practice_session_attempts_path(song_part, session),
           params: velocity_params.to_json,
           headers: { "Content-Type" => "application/json" }
      attempt = SessionAttempt.last
      expect(attempt.played_velocity).to eq(90)
      expect(attempt.expected_velocity).to eq(75)
    end

    it "returns 404 for unknown session" do
      post song_part_practice_session_attempts_path(song_part, 99999),
           params: valid_params.to_json,
           headers: { "Content-Type" => "application/json" }
      expect(response).to have_http_status(:not_found)
    end
  end
end

require "rails_helper"

RSpec.describe "PracticeSessions", type: :request do
  let!(:song_part) { create(:song_part) }
  let!(:session)   { create(:practice_session, song: song_part.song, song_part: song_part) }

  describe "GET /practice_sessions" do
    it "returns http success" do
      get practice_sessions_path
      expect(response).to have_http_status(:success)
    end

    it "lists sessions in reverse chronological order" do
      older = create(:practice_session, song: song_part.song, song_part: song_part, created_at: 2.days.ago)
      newer = create(:practice_session, song: song_part.song, song_part: song_part, created_at: 1.hour.ago)
      get practice_sessions_path

      body = response.body
      expect(body.index(newer.song.title)).to be < body.index(older.created_at.strftime("%b"))
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

    it "sets initial metadata from the song part" do
      post song_part_practice_sessions_path(song_part)
      created = PracticeSession.last
      expect(created.song).to eq(song_part.song)
      expect(created.total_notes).to eq(song_part.note_count)
      expect(created.started_at).to be_present
    end
  end

  describe "PATCH /practice_sessions/:id/complete" do
    it "marks the session as complete" do
      patch complete_practice_session_path(session), params: { notes_reached: 3, correct_notes: 2, incorrect_notes: 1 }
      session.reload
      expect(session.completed).to be true
    end

    it "computes accuracy percentage from correct and incorrect counts" do
      patch complete_practice_session_path(session), params: { notes_reached: 3, correct_notes: 2, incorrect_notes: 1 }
      session.reload
      expect(session.accuracy_pct).to eq(66.7)
    end

    it "sets ended_at timestamp" do
      patch complete_practice_session_path(session), params: { notes_reached: 3, correct_notes: 3, incorrect_notes: 0 }
      expect(session.reload.ended_at).to be_present
    end

    it "invokes SessionScorer and populates composite score" do
      # Create some session attempts so scorer has data
      session.session_attempts.create!(
        note_position: 0, expected_midi: 60, played_midi: 60,
        correct: true, response_ms: 350
      )
      session.session_attempts.create!(
        note_position: 1, expected_midi: 64, played_midi: 64,
        correct: true, response_ms: 400
      )

      patch complete_practice_session_path(session), params: { notes_reached: 2, correct_notes: 2, incorrect_notes: 0 }
      session.reload
      expect(session.composite_score).to be_present
      expect(session.timing_score).to be_present
    end

    it "responds with turbo_stream when requested" do
      patch complete_practice_session_path(session),
            params: { notes_reached: 3, correct_notes: 3, incorrect_notes: 0 },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("session_complete")
    end

    it "handles zero notes gracefully" do
      patch complete_practice_session_path(session), params: { notes_reached: 0, correct_notes: 0, incorrect_notes: 0 }
      session.reload
      expect(session.completed).to be true
      expect(session.accuracy_pct).to eq(0.0)
    end
  end
end

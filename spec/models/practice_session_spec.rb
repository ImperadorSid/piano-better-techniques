require "rails_helper"

RSpec.describe PracticeSession, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:song) }
    it { is_expected.to belong_to(:song_part) }
    it { is_expected.to have_many(:session_attempts).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:started_at) }
  end

  describe "#complete!" do
    let(:session) { create(:practice_session, correct_notes: 8, incorrect_notes: 2) }

    it "marks session as completed" do
      session.complete!(notes_reached: 10)
      expect(session.reload.completed).to be true
    end

    it "calculates accuracy_pct" do
      session.complete!(notes_reached: 10)
      expect(session.reload.accuracy_pct).to eq(80.0)
    end

    it "sets ended_at" do
      session.complete!
      expect(session.reload.ended_at).not_to be_nil
    end

    it "runs the scorer and populates composite_score" do
      session.record_attempt!(note_position: 0, expected_midi: 60, played_midi: 60, correct: true, response_ms: 500, played_velocity: 75, expected_velocity: 75)
      session.update!(correct_notes: 1, total_notes: 1)
      session.complete!(notes_reached: 1)
      expect(session.reload.composite_score).to be_present
    end
  end

  describe "#score_breakdown" do
    let(:session) { create(:practice_session, accuracy_pct: 90.0, timing_score: 85.0, velocity_score: 80.0, composite_score: 83.5) }

    it "returns a hash with all score dimensions" do
      breakdown = session.score_breakdown
      expect(breakdown).to eq(accuracy: 90.0, timing: 85.0, velocity: 80.0, composite: 83.5)
    end
  end

  describe "#record_attempt!" do
    let(:session) { create(:practice_session, correct_notes: 0, incorrect_notes: 0) }

    it "creates a SessionAttempt record" do
      expect {
        session.record_attempt!(
          note_position: 0,
          expected_midi: 60,
          played_midi: 60,
          correct: true
        )
      }.to change(SessionAttempt, :count).by(1)
    end

    it "increments correct_notes on correct attempt" do
      session.record_attempt!(note_position: 0, expected_midi: 60, played_midi: 60, correct: true)
      expect(session.reload.correct_notes).to eq(1)
    end

    it "increments incorrect_notes on wrong attempt" do
      session.record_attempt!(note_position: 0, expected_midi: 60, played_midi: 62, correct: false)
      expect(session.reload.incorrect_notes).to eq(1)
    end

    it "stores velocity data" do
      session.record_attempt!(
        note_position: 0, expected_midi: 60, played_midi: 60,
        correct: true, played_velocity: 85, expected_velocity: 75
      )
      attempt = session.session_attempts.last
      expect(attempt.played_velocity).to eq(85)
      expect(attempt.expected_velocity).to eq(75)
    end

    it "records missed notes (played_midi: 0) as incorrect" do
      session.record_attempt!(
        note_position: 0, expected_midi: 60, played_midi: 0,
        correct: false, response_ms: nil, played_velocity: 0, expected_velocity: 75
      )
      expect(session.reload.incorrect_notes).to eq(1)
      attempt = session.session_attempts.last
      expect(attempt.played_midi).to eq(0)
      expect(attempt.response_ms).to be_nil
    end
  end

  describe "#complete! with auto-advance data" do
    let(:session) { create(:practice_session, correct_notes: 3, incorrect_notes: 7, total_notes: 10) }

    it "calculates accuracy from correct vs total attempts" do
      session.complete!(notes_reached: 10)
      expect(session.reload.accuracy_pct).to eq(30.0)
    end

    it "stores notes_reached as total notes in song" do
      session.complete!(notes_reached: 10)
      expect(session.reload.notes_reached).to eq(10)
    end

    it "uses client-provided counts when given (overrides accumulated counters)" do
      # Simulate accumulated counters from multiple restarts
      session.update!(correct_notes: 50, incorrect_notes: 100)
      session.complete!(notes_reached: 10, correct_notes: 4, incorrect_notes: 6)
      session.reload
      expect(session.correct_notes).to eq(4)
      expect(session.incorrect_notes).to eq(6)
      expect(session.accuracy_pct).to eq(40.0)
    end

    it "falls back to accumulated counters when client counts not provided" do
      session.complete!(notes_reached: 10)
      session.reload
      expect(session.correct_notes).to eq(3)
      expect(session.incorrect_notes).to eq(7)
    end
  end
end

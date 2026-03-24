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
  end
end

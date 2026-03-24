require "rails_helper"

RSpec.describe SessionAttempt, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:practice_session) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:note_position) }
    it { is_expected.to validate_presence_of(:expected_midi) }
    it { is_expected.to validate_presence_of(:played_midi) }
    it { is_expected.to validate_numericality_of(:note_position).is_greater_than_or_equal_to(0) }
  end

  describe "creation" do
    let(:session) { create(:practice_session) }

    it "creates a valid attempt" do
      attempt = create(:session_attempt, practice_session: session)
      expect(attempt).to be_persisted
      expect(attempt.correct).to be true
    end

    it "creates an incorrect attempt" do
      attempt = create(:session_attempt, :incorrect, practice_session: session)
      expect(attempt.correct).to be false
      expect(attempt.played_midi).not_to eq(attempt.expected_midi)
    end
  end
end

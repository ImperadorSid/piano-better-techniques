require "rails_helper"

RSpec.describe Scoring::SessionScorer do
  let(:session) { create(:practice_session, correct_notes: 0, incorrect_notes: 0, total_notes: 5) }

  def add_attempt(pos:, correct:, response_ms: 500, played_velocity: 75, expected_velocity: 75)
    session.record_attempt!(
      note_position: pos,
      expected_midi: 60 + pos,
      played_midi: correct ? 60 + pos : 99,
      correct: correct,
      response_ms: response_ms,
      played_velocity: played_velocity,
      expected_velocity: expected_velocity
    )
  end

  describe "#calculate!" do
    context "perfect session" do
      before do
        5.times { |i| add_attempt(pos: i, correct: true, response_ms: 500) }
        session.update!(correct_notes: 5, incorrect_notes: 0, accuracy_pct: 100.0)
      end

      it "produces a high composite score" do
        described_class.new(session).calculate!
        session.reload
        expect(session.composite_score).to be >= 95.0
        expect(session.timing_score).to eq(100.0)
        expect(session.velocity_score).to eq(100.0)
      end
    end

    context "all incorrect session" do
      before do
        5.times { |i| add_attempt(pos: i, correct: false, response_ms: 500) }
        session.update!(correct_notes: 0, incorrect_notes: 5, accuracy_pct: 0.0)
      end

      it "has zero accuracy but timing defaults high" do
        described_class.new(session).calculate!
        session.reload
        # Timing defaults to 100 with < 2 correct data points; velocity is nil
        # Composite reflects weighted: accuracy=0, timing=100, velocity redistributed
        expect(session.composite_score).to be < 55.0
      end
    end

    context "timing consistency" do
      it "scores higher for consistent timing" do
        consistent_session = create(:practice_session, correct_notes: 0, incorrect_notes: 0, total_notes: 5)
        5.times { |i|
          consistent_session.record_attempt!(
            note_position: i, expected_midi: 60 + i, played_midi: 60 + i,
            correct: true, response_ms: 500, played_velocity: 75, expected_velocity: 75
          )
        }
        consistent_session.update!(correct_notes: 5, incorrect_notes: 0, accuracy_pct: 100.0)

        inconsistent_session = create(:practice_session, correct_notes: 0, incorrect_notes: 0, total_notes: 5)
        [100, 900, 200, 800, 150].each_with_index { |ms, i|
          inconsistent_session.record_attempt!(
            note_position: i, expected_midi: 60 + i, played_midi: 60 + i,
            correct: true, response_ms: ms, played_velocity: 75, expected_velocity: 75
          )
        }
        inconsistent_session.update!(correct_notes: 5, incorrect_notes: 0, accuracy_pct: 100.0)

        described_class.new(consistent_session).calculate!
        described_class.new(inconsistent_session).calculate!

        expect(consistent_session.reload.timing_score).to be > inconsistent_session.reload.timing_score
      end
    end

    context "velocity scoring" do
      it "gives 100 for exact velocity match" do
        3.times { |i| add_attempt(pos: i, correct: true, played_velocity: 80, expected_velocity: 80) }
        session.update!(correct_notes: 3, accuracy_pct: 100.0, total_notes: 3)
        described_class.new(session).calculate!
        expect(session.reload.velocity_score).to eq(100.0)
      end

      it "penalizes velocity mismatch" do
        3.times { |i| add_attempt(pos: i, correct: true, played_velocity: 40, expected_velocity: 80) }
        session.update!(correct_notes: 3, accuracy_pct: 100.0, total_notes: 3)
        described_class.new(session).calculate!
        expect(session.reload.velocity_score).to be < 50.0
      end
    end

    context "no velocity data" do
      before do
        3.times { |i| add_attempt(pos: i, correct: true, played_velocity: nil, expected_velocity: nil) }
        session.update!(correct_notes: 3, accuracy_pct: 100.0, total_notes: 3)
      end

      it "sets velocity_score to nil" do
        described_class.new(session).calculate!
        expect(session.reload.velocity_score).to be_nil
      end

      it "still calculates a composite score (redistributes weight)" do
        described_class.new(session).calculate!
        expect(session.reload.composite_score).to be > 0
      end
    end

    context "single note session" do
      it "handles gracefully" do
        add_attempt(pos: 0, correct: true, response_ms: 500)
        session.update!(correct_notes: 1, accuracy_pct: 100.0, total_notes: 1)
        described_class.new(session).calculate!
        session.reload
        expect(session.composite_score).to be_present
        expect(session.timing_score).to eq(100.0) # < 2 data points
      end
    end

    context "session with no correct attempts" do
      it "handles gracefully" do
        add_attempt(pos: 0, correct: false)
        session.update!(incorrect_notes: 1, accuracy_pct: 0.0)
        described_class.new(session).calculate!
        session.reload
        expect(session.composite_score).to be_present
      end
    end
  end
end

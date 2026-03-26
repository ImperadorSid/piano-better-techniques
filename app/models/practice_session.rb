class PracticeSession < ApplicationRecord
  belongs_to :song
  belongs_to :song_part
  has_many :session_attempts, dependent: :destroy

  attribute :completed, :boolean, default: false
  attribute :correct_notes, :integer, default: 0
  attribute :incorrect_notes, :integer, default: 0
  attribute :notes_reached, :integer, default: 0

  validates :started_at, presence: true

  def complete!(notes_reached: nil)
    total = correct_notes.to_i + incorrect_notes.to_i
    pct = total > 0 ? (correct_notes.to_f / total * 100).round(1) : 0.0
    update!(
      completed: true,
      ended_at: Time.current,
      notes_reached: notes_reached || self.notes_reached,
      accuracy_pct: pct
    )
    Scoring::SessionScorer.new(self).calculate!
  end

  def score_breakdown
    {
      accuracy: accuracy_pct,
      timing: timing_score,
      velocity: velocity_score,
      composite: composite_score
    }
  end

  def record_attempt!(note_position:, expected_midi:, played_midi:, correct:, response_ms: nil, played_velocity: nil, expected_velocity: nil)
    session_attempts.create!(
      note_position: note_position,
      expected_midi: expected_midi,
      played_midi: played_midi,
      correct: correct,
      response_ms: response_ms,
      played_velocity: played_velocity,
      expected_velocity: expected_velocity
    )
    if correct
      increment!(:correct_notes)
    else
      increment!(:incorrect_notes)
    end
  end
end

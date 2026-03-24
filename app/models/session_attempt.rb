class SessionAttempt < ApplicationRecord
  belongs_to :practice_session

  validates :note_position, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :expected_midi, presence: true
  validates :played_midi, presence: true
end

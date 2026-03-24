class SongPart < ApplicationRecord
  belongs_to :song
  has_many :practice_sessions, dependent: :destroy

  HANDS = %w[right left both].freeze

  validates :name, presence: true
  validates :hand, inclusion: { in: HANDS }
  validates :notes_data, presence: true

  def notes
    notes_data || []
  end

  def note_count
    notes.size
  end
end

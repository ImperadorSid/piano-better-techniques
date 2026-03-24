class Song < ApplicationRecord
  has_many :song_parts, dependent: :destroy
  has_one :song_analysis, dependent: :destroy
  has_many :practice_sessions, dependent: :destroy

  IMPORT_STATUSES = %w[pending processing ready failed].freeze
  DIFFICULTY_LABELS = { 1 => "Beginner", 2 => "Easy", 3 => "Intermediate", 4 => "Advanced", 5 => "Expert" }.freeze

  validates :title, presence: true
  validates :difficulty, numericality: { in: 1..5 }, allow_nil: true
  validates :import_status, inclusion: { in: IMPORT_STATUSES }
  validates :tempo_bpm, numericality: { greater_than: 0 }, allow_nil: true

  attribute :import_status, :string, default: "pending"
  attribute :tempo_bpm, :integer, default: 120
  attribute :time_signature, :string, default: "4/4"
  attribute :key_signature, :string, default: "C"

  scope :ready, -> { where(import_status: "ready") }
  scope :by_difficulty, -> { order(:difficulty) }

  def difficulty_label
    DIFFICULTY_LABELS[difficulty] || "Unknown"
  end

  def ready?
    import_status == "ready"
  end
end

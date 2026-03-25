class SongAnalysis < ApplicationRecord
  belongs_to :song

  def chord_progressions
    super || []
  end

  def difficulty_sections
    super || []
  end

  def dynamics_map
    super || []
  end

  def hand_separation
    super || {}
  end

  def ai_generated?
    ai_overview.present?
  end
end

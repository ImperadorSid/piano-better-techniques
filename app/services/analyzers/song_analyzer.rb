module Analyzers
  # Orchestrates all analysis passes on a song after import.
  # Builds or updates the SongAnalysis record.
  class SongAnalyzer
    def initialize(song)
      @song = song
    end

    def analyze!
      chord_progressions  = ChordDetector.new(@song).analyze
      difficulty_sections = DifficultyScorer.new(@song).analyze
      scorer              = DifficultyScorer.new(@song)
      dynamics_map        = scorer.dynamics_map
      hand_separation     = HandSeparator.new(@song).analyze

      overall_difficulty  = difficulty_sections.any? ? difficulty_sections.sum { |s| s["level"] } / difficulty_sections.size : 1
      @song.difficulty    = overall_difficulty.round.clamp(1, 5)
      @song.total_notes   = @song.song_parts.sum(&:note_count)

      analysis = @song.song_analysis || @song.build_song_analysis
      analysis.assign_attributes(
        chord_progressions:  chord_progressions,
        difficulty_sections: difficulty_sections,
        dynamics_map:        dynamics_map,
        hand_separation:     hand_separation
      )
      analysis.save!
      @song.save!
    end
  end
end

module Analyzers
  # Scores the difficulty of song sections based on:
  # - Note density (notes per beat)
  # - Pitch range
  # - Velocity variation
  class DifficultyScorer
    SECTION_SIZE_BEATS = 8  # analyze in 8-beat windows

    def initialize(song)
      @song = song
    end

    def analyze
      notes = all_notes
      return [] if notes.empty?

      total_beats = notes.map { |n| n["beat"].to_f }.max || 0
      sections = []

      start_beat = 0
      while start_beat <= total_beats
        end_beat = start_beat + SECTION_SIZE_BEATS
        window = notes.select { |n| n["beat"].to_f.between?(start_beat, end_beat) }

        if window.any?
          level = score_window(window, end_beat - start_beat)
          sections << {
            "start_beat" => start_beat,
            "end_beat"   => end_beat,
            "level"      => level,
            "label"      => section_label(start_beat, total_beats)
          }
        end

        start_beat = end_beat
      end

      sections
    end

    def dynamics_map(notes = nil)
      notes ||= all_notes
      return [] if notes.empty?

      notes.group_by { |n| (n["beat"].to_f / 4).floor }.map do |window_idx, window_notes|
        avg_vel = window_notes.sum { |n| n["vel"].to_i }.to_f / window_notes.size
        {
          "beat"         => window_idx * 4,
          "velocity_avg" => avg_vel.round,
          "marking"      => velocity_to_marking(avg_vel)
        }
      end
    end

    private

    def all_notes
      @song.song_parts.flat_map { |p| p.notes_data || [] }
    end

    def score_window(notes, beats)
      density     = notes.size.to_f / [beats, 1].max
      pitch_range = notes.map { |n| n["midi"].to_i }.then { |m| m.max - m.min }
      vel_range   = notes.map { |n| n["vel"].to_i }.then { |v| v.max - v.min }

      score = 1
      score += 1 if density > 2
      score += 1 if density > 4
      score += 1 if pitch_range > 14   # more than a 9th interval
      score += 1 if vel_range > 40     # significant dynamics variation

      score.clamp(1, 5)
    end

    def section_label(start_beat, total_beats)
      pct = start_beat.to_f / total_beats
      return "Intro" if pct < 0.15
      return "Outro" if pct > 0.85
      return "Build" if pct < 0.35
      return "Climax" if pct.between?(0.45, 0.65)
      "Main"
    end

    def velocity_to_marking(velocity)
      case velocity
      when 0..19   then "pp"
      when 20..39  then "p"
      when 40..63  then "mp"
      when 64..87  then "mf"
      when 88..111 then "f"
      else              "ff"
      end
    end
  end
end

module Analyzers
  # Detects chord names from groups of simultaneous notes.
  # For a melody-only track, uses a simple harmonic analysis
  # based on frequent note patterns.
  class ChordDetector
    CHORD_INTERVALS = {
      "major"      => [0, 4, 7],
      "minor"      => [0, 3, 7],
      "dominant"   => [0, 4, 7, 10],
      "diminished" => [0, 3, 6],
      "augmented"  => [0, 4, 8]
    }.freeze

    NOTE_NAMES = %w[C C# D D# E F F# G G# A A# B].freeze

    def initialize(song)
      @song = song
    end

    def analyze
      notes = all_notes
      return [] if notes.empty?

      # Group notes by beat window (every 2 beats)
      windows = notes.group_by { |n| (n["beat"].to_f / 2).floor }

      windows.map do |window_idx, window_notes|
        pitches = window_notes.map { |n| n["midi"].to_i % 12 }.uniq
        beat = window_idx * 2

        root, quality = detect_chord(pitches)
        next unless root

        {
          "beat"    => beat,
          "chord"   => NOTE_NAMES[root],
          "quality" => quality
        }
      end.compact
    end

    private

    def all_notes
      @song.song_parts.flat_map { |p| p.notes_data || [] }
    end

    def detect_chord(pitches)
      return nil if pitches.empty?

      # Try each pitch class as a potential root
      pitches.each do |root|
        intervals = pitches.map { |p| (p - root) % 12 }.sort

        CHORD_INTERVALS.each do |quality, chord_intervals|
          if (chord_intervals - intervals).empty?
            return [root, quality]
          end
        end
      end

      # Fall back to the most frequent pitch as root
      [pitches.first, "major"]
    end
  end
end

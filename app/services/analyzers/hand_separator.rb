module Analyzers
  # Determines the split point between left and right hand parts
  # by computing the median pitch of notes in each track.
  class HandSeparator
    MIDDLE_C = 60

    def initialize(song)
      @song = song
    end

    def analyze
      return {} if @song.song_parts.empty?

      all_notes = @song.song_parts.flat_map { |p| p.notes_data || [] }
      return {} if all_notes.empty?

      avg_pitch = all_notes.sum { |n| n["midi"].to_i }.to_f / all_notes.size
      split_point = (avg_pitch + MIDDLE_C) / 2

      {
        "split_midi" => split_point.round,
        "avg_pitch"  => avg_pitch.round(1),
        "method"     => "pitch_median"
      }
    end
  end
end

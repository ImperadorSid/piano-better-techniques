require "faraday"

module Importers
  # Parses a subset of ABC notation sufficient for extracting a melody line.
  # Reference: https://abcnotation.com/wiki/abc:standard:v2.1
  class AbcImporter
    NOTE_BASES = { "C" => 0, "D" => 2, "E" => 4, "F" => 5, "G" => 7, "A" => 9, "B" => 11 }.freeze
    # Octave 4 = uppercase notes (C=60, D=62…), octave 5 = lowercase (c=72…)
    BASE_OCTAVE_MIDI = 60  # middle C (C4)

    def initialize(source)
      # source can be:
      #   - A raw ABC notation string
      #   - A URL to thesession.org (will be fetched)
      @source = source
    end

    def import_into(song)
      abc_text = fetch_abc
      return fail_song(song, "Could not fetch ABC notation") if abc_text.blank?

      parse_headers(abc_text, song)
      notes = parse_body(abc_text)
      return fail_song(song, "No notes found in ABC") if notes.empty?

      song.song_parts.build(
        name: "Melody",
        hand: "right",
        notes_data: notes,
        note_count: notes.size
      )
      song.import_status = "ready"
      song
    rescue StandardError => e
      fail_song(song, e.message)
    end

    private

    def fetch_abc
      if @source.start_with?("http")
        fetch_from_url(@source)
      else
        @source
      end
    end

    def fetch_from_url(url)
      # thesession.org: convert HTML URL to JSON API endpoint
      url = url.gsub("thesession.org/tunes/", "thesession.org/tunes/").strip
      if url =~ /thesession\.org\/tunes\/(\d+)/
        tune_id = $1
        api_url = "https://thesession.org/tunes/#{tune_id}?format=json"
        response = Faraday.get(api_url)
        data = JSON.parse(response.body)
        # First setting has the ABC
        return data["settings"]&.first&.dig("abc") || ""
      end

      # Generic URL: attempt to fetch raw ABC text
      Faraday.get(url).body
    rescue Faraday::Error => e
      Rails.logger.error "[AbcImporter] HTTP error: #{e.message}"
      ""
    end

    def parse_headers(text, song)
      text.each_line do |line|
        line = line.strip
        if line.start_with?("T:") && song.title == "Imported Song"
          song.title = line[2..].strip
        elsif line.start_with?("Q:")
          match = line.match(/(\d+)/)
          song.tempo_bpm = match[1].to_i if match
        elsif line.start_with?("M:")
          song.time_signature = line[2..].strip
        elsif line.start_with?("K:")
          song.key_signature = line[2..].strip.split.first
        end
      end
    end

    def parse_body(text)
      # Strip header lines (lines before the first body line)
      in_body = false
      body = text.lines.select do |line|
        in_body ||= line.match?(/^[A-Ga-g|]/) && !line.match?(/^[A-Za-z]:/)
        in_body
      end.join

      # Remove bar lines, repeat marks, and other non-note characters
      body = body.gsub(/[|:\[\]{}]/, " ").gsub(/%.*$/, "")

      notes = []
      pos = 0
      beat = 0.0
      # Match notes: optional accidentals, note letter, optional octave markers, optional duration
      body.scan(/([_^=]?)([A-Ga-gz])([',]*)(\d*\/?\d*)/) do |acc, note_char, octave_mod, dur_str|
        next if note_char == "z"  # rest

        midi = note_char_to_midi(note_char, acc, octave_mod)
        next unless midi

        duration = parse_duration(dur_str)

        notes << {
          "pos"  => pos,
          "midi" => midi,
          "name" => midi_to_name(midi),
          "dur"  => duration,
          "vel"  => 80,
          "beat" => beat.round(3)
        }
        pos += 1
        beat += duration
      end

      notes
    end

    def note_char_to_midi(char, accidental, octave_mod)
      base = NOTE_BASES[char.upcase]
      return nil unless base

      # Lowercase = one octave higher than uppercase
      octave = char == char.upcase ? 4 : 5

      # Apply octave modifiers: ' raises, , lowers
      octave += octave_mod.count("'")
      octave -= octave_mod.count(",")

      # Accidentals
      acc_offset = case accidental
      when "^" then 1
      when "_" then -1
      else 0
      end

      (octave + 1) * 12 + base + acc_offset
    end

    def parse_duration(dur_str)
      return 1.0 if dur_str.blank?
      if dur_str.include?("/")
        parts = dur_str.split("/")
        num = parts[0].presence&.to_f || 1.0
        den = parts[1].presence&.to_f || 2.0
        num / den
      else
        dur_str.to_f
      end
    end

    def midi_to_name(midi)
      names = %w[C C# D D# E F F# G G# A A# B]
      octave = (midi / 12) - 1
      "#{names[midi % 12]}#{octave}"
    end

    def fail_song(song, reason)
      Rails.logger.error "[AbcImporter] #{reason}"
      song.import_status = "failed"
      song
    end
  end
end

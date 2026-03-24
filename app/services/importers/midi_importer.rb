require "midilib/sequence"
require "midilib/io/seqreader"
require "midilib/io/seqwriter"

module Importers
  class MidiImporter
    MIDDLE_C = 60  # MIDI note number for C4

    def initialize(source)
      # source can be a File object, a path string, or raw binary string
      @source = source
    end

    def import_into(song)
      sequence = parse_midi
      apply_tempo(song, sequence)
      extract_parts(song, sequence)
      song.import_status = "ready"
      song
    rescue StandardError => e
      song.import_status = "failed"
      Rails.logger.error "[MidiImporter] Failed: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
      song
    end

    private

    def parse_midi
      seq = MIDI::Sequence.new
      case @source
      when String
        if @source.length < 4096 && file_path?(@source)
          File.open(@source, "rb") { |f| seq.read(f) }
        else
          io = StringIO.new(@source.b)
          seq.read(io)
        end
      else
        @source.rewind if @source.respond_to?(:rewind)
        seq.read(@source)
      end
      seq
    end

    def apply_tempo(song, sequence)
      song.tempo_bpm = sequence.tempo > 0 ? (60_000_000.0 / sequence.tempo).round : 120
      song.time_signature = extract_time_signature(sequence)
      song.key_signature = extract_key_signature(sequence)
    end

    def extract_parts(song, sequence)
      note_tracks = sequence.tracks.reject { |t| tempo_track?(t) }

      note_tracks.each_with_index do |track, idx|
        notes = extract_notes(track, sequence.ppqn)
        next if notes.empty?

        hand = infer_hand(notes, idx)
        name = track.name.presence || (hand == "right" ? "Melody" : "Accompaniment")

        song.song_parts.build(
          name: name,
          hand: hand,
          notes_data: notes,
          note_count: notes.size
        )
      end
    end

    def extract_notes(track, ppqn)
      notes = []
      pos = 0
      cumulative_ticks = 0

      track.each do |event|
        cumulative_ticks += event.delta_time

        next unless event.is_a?(MIDI::NoteOn) && event.velocity > 0

        beat = cumulative_ticks.to_f / ppqn
        notes << {
          "pos"  => pos,
          "midi" => event.note,
          "name" => midi_to_name(event.note),
          "dur"  => event.delta_time.to_f / ppqn,
          "vel"  => event.velocity,
          "beat" => beat.round(3)
        }
        pos += 1
      end

      notes
    end

    def infer_hand(notes, track_index)
      return "right" if track_index == 0
      avg_pitch = notes.sum { |n| n["midi"] }.to_f / notes.size
      avg_pitch >= MIDDLE_C ? "right" : "left"
    end

    def midi_to_name(midi)
      names = %w[C C# D D# E F F# G G# A A# B]
      octave = (midi / 12) - 1
      "#{names[midi % 12]}#{octave}"
    end

    def tempo_track?(track)
      !track.events.any? { |e| e.is_a?(MIDI::NoteOn) }
    rescue
      false
    end

    def extract_time_signature(sequence)
      event = sequence.tracks.flat_map(&:events).find { |e| e.is_a?(MIDI::MetaEvent) && e.respond_to?(:numerator) }
      return "4/4" unless event
      "#{event.numerator}/#{2**event.denominator}"
    rescue
      "4/4"
    end

    def extract_key_signature(sequence)
      "C"
    rescue
      "C"
    end

    def file_path?(str)
      File.exist?(str)
    rescue ArgumentError
      false
    end
  end
end

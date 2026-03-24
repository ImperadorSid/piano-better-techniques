require "rails_helper"
require "midilib/sequence"
require "midilib/io/seqreader"
require "midilib/io/seqwriter"

RSpec.describe Importers::MidiImporter do
  let(:song) { create(:song, import_status: "pending") }

  # Generate a valid MIDI binary using midilib itself — ensures format compatibility
  def generate_midi_binary
    seq = MIDI::Sequence.new
    seq.ppqn = 480

    track = MIDI::Track.new(seq)
    seq.tracks << track
    track.name = "Test Track"

    note_on = MIDI::NoteOn.new(0, 60, 80)
    note_on.delta_time = 0
    track.events << note_on

    note_off = MIDI::NoteOff.new(0, 60, 0)
    note_off.delta_time = 120
    track.events << note_off

    io = StringIO.new("".b)
    seq.write(io)
    io.rewind
    io.read
  end

  describe "#import_into" do
    context "with a valid MIDI binary string" do
      let(:midi_binary) { generate_midi_binary }

      subject(:importer) { described_class.new(midi_binary) }

      it "sets import_status to ready" do
        importer.import_into(song)
        expect(song.import_status).to eq("ready")
      end

      it "builds at least one song part" do
        importer.import_into(song)
        expect(song.song_parts).not_to be_empty
      end

      it "extracts C4 (MIDI 60) as a note" do
        importer.import_into(song)
        notes = song.song_parts.flat_map(&:notes_data)
        expect(notes.any? { |n| n["midi"] == 60 }).to be true
      end
    end

    context "with invalid binary" do
      subject(:importer) { described_class.new("not valid midi") }

      it "sets import_status to failed" do
        importer.import_into(song)
        expect(song.import_status).to eq("failed")
      end
    end
  end
end

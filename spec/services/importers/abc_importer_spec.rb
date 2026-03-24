require "rails_helper"

RSpec.describe Importers::AbcImporter do
  let(:song) { create(:song, title: "Imported Song", import_status: "pending") }

  let(:simple_abc) do
    <<~ABC
      X:1
      T:Simple Tune
      M:4/4
      Q:120
      K:C
      CDEF GABc|
    ABC
  end

  describe "#import_into" do
    subject(:importer) { described_class.new(simple_abc) }

    it "sets the song title from the ABC header" do
      importer.import_into(song)
      expect(song.title).to eq("Simple Tune")
    end

    it "sets tempo_bpm from Q: header" do
      importer.import_into(song)
      expect(song.tempo_bpm).to eq(120)
    end

    it "sets time_signature from M: header" do
      importer.import_into(song)
      expect(song.time_signature).to eq("4/4")
    end

    it "sets import_status to ready on success" do
      importer.import_into(song)
      expect(song.import_status).to eq("ready")
    end

    it "builds a song part with notes" do
      importer.import_into(song)
      expect(song.song_parts).not_to be_empty
    end

    it "extracts notes with correct MIDI values" do
      importer.import_into(song)
      notes = song.song_parts.first.notes_data
      # C4 = MIDI 60
      expect(notes.first["midi"]).to eq(60)
    end

    context "with blank source" do
      subject(:importer) { described_class.new("") }

      it "sets import_status to failed" do
        importer.import_into(song)
        expect(song.import_status).to eq("failed")
      end
    end
  end
end

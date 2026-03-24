require "rails_helper"

RSpec.describe Analyzers::ChordDetector do
  let(:song) { create(:song) }

  describe "#analyze" do
    context "with C major triad notes (C E G)" do
      before do
        song.song_parts.create!(
          name: "Test",
          hand: "right",
          notes_data: [
            { "pos" => 0, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
            { "pos" => 1, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 0.5 },
            { "pos" => 2, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 1.0 }
          ],
          note_count: 3
        )
      end

      it "returns an array of chord entries" do
        result = described_class.new(song).analyze
        expect(result).to be_an(Array)
      end

      it "returns entries with chord, beat, and quality" do
        result = described_class.new(song).analyze
        expect(result.first).to include("chord", "beat", "quality")
      end

      it "detects a major chord" do
        result = described_class.new(song).analyze
        expect(result.any? { |c| c["quality"] == "major" }).to be true
      end
    end

    context "with empty song" do
      it "returns an empty array" do
        expect(described_class.new(song).analyze).to eq([])
      end
    end
  end
end

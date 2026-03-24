require "rails_helper"

RSpec.describe Analyzers::HandSeparator do
  let(:song) { create(:song) }

  describe "#analyze" do
    context "with notes in the right hand range (above C4)" do
      before do
        song.song_parts.create!(
          name: "Melody",
          hand: "right",
          notes_data: [
            { "pos" => 0, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
            { "pos" => 1, "midi" => 67, "name" => "G4", "dur" => 1.0, "vel" => 80, "beat" => 1.0 }
          ],
          note_count: 2
        )
      end

      it "returns a hash with split_midi and method" do
        result = described_class.new(song).analyze
        expect(result).to include("split_midi", "method")
      end

      it "returns pitch_median as method" do
        expect(described_class.new(song).analyze["method"]).to eq("pitch_median")
      end
    end

    context "with no song parts" do
      it "returns empty hash" do
        expect(described_class.new(song).analyze).to eq({})
      end
    end
  end
end

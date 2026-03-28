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

      it "includes avg_pitch" do
        result = described_class.new(song).analyze
        expect(result).to include("avg_pitch")
      end
    end

    context "with notes spanning both hands" do
      before do
        song.song_parts.create!(
          name: "Full",
          hand: "both",
          notes_data: [
            { "pos" => 0, "midi" => 48, "name" => "C3", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
            { "pos" => 1, "midi" => 72, "name" => "C5", "dur" => 1.0, "vel" => 80, "beat" => 1.0 }
          ],
          note_count: 2
        )
      end

      it "calculates split_midi between low and high notes" do
        result = described_class.new(song).analyze
        # avg_pitch = (48+72)/2 = 60, split = (60+60)/2 = 60
        expect(result["split_midi"]).to eq(60)
      end
    end

    context "with notes in the left hand range (below C4)" do
      before do
        song.song_parts.create!(
          name: "Bass",
          hand: "left",
          notes_data: [
            { "pos" => 0, "midi" => 40, "name" => "E2", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
            { "pos" => 1, "midi" => 45, "name" => "A2", "dur" => 1.0, "vel" => 80, "beat" => 1.0 }
          ],
          note_count: 2
        )
      end

      it "places split point below middle C for low notes" do
        result = described_class.new(song).analyze
        expect(result["split_midi"]).to be < 60
      end
    end

    context "with no song parts" do
      it "returns empty hash" do
        expect(described_class.new(song).analyze).to eq({})
      end
    end

    context "with song parts but nil notes" do
      before do
        part = song.song_parts.create!(
          name: "Empty",
          hand: "right",
          notes_data: [{ "pos" => 0, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 0.0 }],
          note_count: 1
        )
        part.update_column(:notes_data, nil)
      end

      it "returns empty hash" do
        expect(described_class.new(song).analyze).to eq({})
      end
    end
  end
end

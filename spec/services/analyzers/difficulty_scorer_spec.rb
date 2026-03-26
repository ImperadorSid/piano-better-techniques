require "rails_helper"

RSpec.describe Analyzers::DifficultyScorer do
  let(:song) { create(:song) }
  let(:simple_notes) do
    [
      { "pos" => 0, "midi" => 60, "name" => "C4", "dur" => 1.0, "vel" => 80, "beat" => 0.0 },
      { "pos" => 1, "midi" => 62, "name" => "D4", "dur" => 1.0, "vel" => 80, "beat" => 1.0 },
      { "pos" => 2, "midi" => 64, "name" => "E4", "dur" => 1.0, "vel" => 80, "beat" => 2.0 }
    ]
  end

  before do
    song.song_parts.create!(
      name: "Melody", hand: "right",
      notes_data: simple_notes, note_count: simple_notes.size
    )
  end

  describe "#analyze" do
    it "returns an array of section hashes" do
      result = described_class.new(song).analyze
      expect(result).to be_an(Array)
      expect(result).not_to be_empty
    end

    it "each section has start_beat, end_beat, level, label" do
      result = described_class.new(song).analyze
      expect(result.first).to include("start_beat", "end_beat", "level", "label")
    end

    it "difficulty level is between 1 and 5" do
      result = described_class.new(song).analyze
      result.each { |s| expect(s["level"]).to be_between(1, 5) }
    end
  end

  describe "#dynamics_map" do
    it "returns an array of dynamic entries" do
      result = described_class.new(song).dynamics_map
      expect(result).to be_an(Array)
      expect(result.first).to include("beat", "velocity_avg", "marking")
    end

    it "includes a known dynamic marking" do
      result = described_class.new(song).dynamics_map
      valid_markings = %w[Light Medium Heavy]
      expect(valid_markings).to include(result.first["marking"])
    end
  end
end

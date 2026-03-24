require "rails_helper"

RSpec.describe SongAnalysis, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:song) }
  end

  describe "json defaults" do
    subject(:analysis) { SongAnalysis.new }

    it "returns empty array for chord_progressions" do
      expect(analysis.chord_progressions).to eq([])
    end

    it "returns empty array for difficulty_sections" do
      expect(analysis.difficulty_sections).to eq([])
    end

    it "returns empty hash for hand_separation" do
      expect(analysis.hand_separation).to eq({})
    end
  end

  describe "persisting JSON fields" do
    let(:song) { create(:song) }

    it "stores and retrieves chord_progressions as array" do
      chords = [ { "beat" => 0, "chord" => "C", "quality" => "major" } ]
      analysis = song.create_song_analysis!(chord_progressions: chords)
      expect(analysis.reload.chord_progressions).to eq(chords)
    end
  end
end

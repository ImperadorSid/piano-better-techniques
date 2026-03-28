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

    it "returns empty array for dynamics_map" do
      expect(analysis.dynamics_map).to eq([])
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

  describe "#ai_generated?" do
    let(:analysis) { create(:song_analysis) }

    it "returns true when ai_overview is present" do
      analysis.update!(ai_overview: '{"mood": "Happy"}')
      expect(analysis.ai_generated?).to be true
    end

    it "returns false when ai_overview is nil" do
      analysis.update!(ai_overview: nil)
      expect(analysis.ai_generated?).to be false
    end

    it "returns false when ai_overview is blank" do
      analysis.update!(ai_overview: "")
      expect(analysis.ai_generated?).to be false
    end
  end

  describe "#ai_pending?" do
    let(:analysis) { create(:song_analysis) }

    it "returns true when ai_status is pending" do
      analysis.update!(ai_status: "pending")
      expect(analysis.ai_pending?).to be true
    end

    it "returns false when ai_status is nil" do
      analysis.update!(ai_status: nil)
      expect(analysis.ai_pending?).to be false
    end

    it "returns false when ai_status is failed" do
      analysis.update!(ai_status: "failed")
      expect(analysis.ai_pending?).to be false
    end
  end

  describe "#ai_failed?" do
    let(:analysis) { create(:song_analysis) }

    it "returns true when ai_status is failed" do
      analysis.update!(ai_status: "failed")
      expect(analysis.ai_failed?).to be true
    end

    it "returns false when ai_status is nil" do
      analysis.update!(ai_status: nil)
      expect(analysis.ai_failed?).to be false
    end

    it "returns false when ai_status is pending" do
      analysis.update!(ai_status: "pending")
      expect(analysis.ai_failed?).to be false
    end
  end
end

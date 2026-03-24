require "rails_helper"

RSpec.describe Analyzers::SongAnalyzer do
  let(:song) { create(:song, :with_part) }

  describe "#analyze!" do
    it "creates a SongAnalysis record" do
      expect { described_class.new(song).analyze! }
        .to change { SongAnalysis.count }.by(1)
    end

    it "sets difficulty on the song" do
      described_class.new(song).analyze!
      expect(song.reload.difficulty).to be_between(1, 5)
    end

    it "sets total_notes on the song" do
      described_class.new(song).analyze!
      expect(song.reload.total_notes).to be_positive
    end

    it "populates chord_progressions" do
      described_class.new(song).analyze!
      expect(song.song_analysis.chord_progressions).not_to be_empty
    end

    it "populates difficulty_sections" do
      described_class.new(song).analyze!
      expect(song.song_analysis.difficulty_sections).not_to be_empty
    end

    context "when analysis already exists" do
      before { create(:song_analysis, song: song) }

      it "updates the existing analysis instead of creating a new one" do
        expect { described_class.new(song).analyze! }
          .not_to change(SongAnalysis, :count)
      end
    end
  end
end

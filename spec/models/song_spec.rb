require "rails_helper"

RSpec.describe Song, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:song_parts).dependent(:destroy) }
    it { is_expected.to have_one(:song_analysis).dependent(:destroy) }
    it { is_expected.to have_many(:practice_sessions).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_inclusion_of(:import_status).in_array(Song::IMPORT_STATUSES) }
  end

  describe "defaults" do
    subject(:song) { Song.new }

    it "defaults import_status to pending" do
      expect(song.import_status).to eq("pending")
    end

    it "defaults tempo_bpm to 120" do
      expect(song.tempo_bpm).to eq(120)
    end
  end

  describe "#difficulty_label" do
    it { expect(build(:song, difficulty: 1).difficulty_label).to eq("Beginner") }
    it { expect(build(:song, difficulty: 3).difficulty_label).to eq("Intermediate") }
    it { expect(build(:song, difficulty: 5).difficulty_label).to eq("Expert") }
  end

  describe "#ready?" do
    it "returns true when import_status is ready" do
      expect(build(:song, import_status: "ready").ready?).to be true
    end

    it "returns false when not ready" do
      expect(build(:song, import_status: "pending").ready?).to be false
    end
  end

  describe "scopes" do
    let!(:ready_song) { create(:song, import_status: "ready", difficulty: 2) }
    let!(:pending_song) { create(:song, import_status: "pending") }

    it "Song.ready returns only ready songs" do
      expect(Song.ready).to include(ready_song)
      expect(Song.ready).not_to include(pending_song)
    end

    it "Song.by_difficulty orders ascending" do
      easy = create(:song, import_status: "ready", difficulty: 1)
      hard = create(:song, import_status: "ready", difficulty: 5)
      result = Song.ready.by_difficulty.to_a
      expect(result.map(&:difficulty)).to eq(result.map(&:difficulty).sort)
    end
  end
end

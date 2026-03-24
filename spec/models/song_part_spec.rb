require "rails_helper"

RSpec.describe SongPart, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:song) }
    it { is_expected.to have_many(:practice_sessions).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:hand).in_array(SongPart::HANDS) }
    it { is_expected.to validate_presence_of(:notes_data) }
  end

  describe "#notes" do
    it "returns notes_data array" do
      notes = [ { "pos" => 0, "midi" => 60 } ]
      part = build(:song_part, notes_data: notes)
      expect(part.notes).to eq(notes)
    end

    it "returns empty array when notes_data is nil" do
      part = SongPart.new
      expect(part.notes).to eq([])
    end
  end

  describe "#note_count" do
    it "returns the number of notes" do
      part = build(:song_part)
      expect(part.note_count).to eq(part.notes_data.size)
    end
  end
end

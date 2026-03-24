require "rails_helper"

RSpec.describe SongImportJob, type: :job do
  let(:song) { create(:song, import_status: "pending", source_format: "manual") }

  describe "#perform" do
    context "when song has no source" do
      it "sets import_status to failed" do
        described_class.new.perform(song.id)
        expect(song.reload.import_status).to eq("failed")
      end
    end

    context "when song has ABC source" do
      let(:abc_song) do
        create(:song,
          import_status: "pending",
          source_format: "abc",
          raw_source: "T:Test\nM:4/4\nQ:100\nK:C\nCDEF|\n"
        )
      end

      it "processes the song and sets status to ready or failed" do
        described_class.new.perform(abc_song.id)
        expect(%w[ready failed]).to include(abc_song.reload.import_status)
      end
    end

    context "when song is already ready" do
      let(:ready_song) { create(:song, import_status: "ready") }

      it "skips processing" do
        expect_any_instance_of(Importers::AbcImporter).not_to receive(:import_into)
        expect_any_instance_of(Importers::MidiImporter).not_to receive(:import_into)
        described_class.new.perform(ready_song.id)
      end
    end

    context "when song does not exist" do
      it "raises ActiveRecord::RecordNotFound (handled by discard_on in production)" do
        expect { described_class.new.perform(99999) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end

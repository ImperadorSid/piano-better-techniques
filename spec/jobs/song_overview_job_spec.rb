require "rails_helper"

RSpec.describe SongOverviewJob do
  let(:song) { create(:song, :with_analysis) }
  let(:analysis) { song.song_analysis }

  let(:successful_response) do
    body = {
      "overview" => "A fun beginner song.",
      "song_map" => "Verse then chorus.",
      "hand_positions" => "Right plays melody. Left plays chords.",
      "difficult_sections" => "The middle part moves fast.",
      "harmony" => "Bright and cheerful major chords."
    }.to_json

    double(success?: true, body: { "content" => [ { "text" => body } ] })
  end

  let(:failed_response) do
    double(success?: false, body: { "error" => "Unauthorized" })
  end

  around do |example|
    original = ENV["ANTHROPIC_API_KEY"]
    ENV["ANTHROPIC_API_KEY"] = "test-key"
    example.run
    ENV["ANTHROPIC_API_KEY"] = original
  end

  describe "#perform" do
    context "when generation succeeds" do
      before do
        analysis.update!(ai_status: "pending")
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(successful_response)
        allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      end

      it "populates the AI fields" do
        described_class.new.perform(song.id)
        expect(analysis.reload.ai_overview).to eq("A fun beginner song.")
      end

      it "clears ai_status" do
        described_class.new.perform(song.id)
        expect(analysis.reload.ai_status).to be_nil
      end

      it "broadcasts a Turbo Stream replace to the song's channel" do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
          "song_overview_#{song.id}",
          hash_including(target: "ai_overview")
        )
        described_class.new.perform(song.id)
      end
    end

    context "when the API call fails" do
      before do
        analysis.update!(ai_status: "pending")
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(failed_response)
        allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      end

      it "sets ai_status to failed" do
        described_class.new.perform(song.id)
        expect(analysis.reload.ai_status).to eq("failed")
      end

      it "broadcasts the failed state" do
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
          "song_overview_#{song.id}",
          hash_including(target: "ai_overview")
        )
        described_class.new.perform(song.id)
      end
    end

    context "when an unexpected error occurs" do
      before do
        analysis.update!(ai_status: "pending")
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::ConnectionFailed.new("timeout"))
        allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
      end

      it "does not raise" do
        expect { described_class.new.perform(song.id) }.not_to raise_error
      end

      it "sets ai_status to failed" do
        described_class.new.perform(song.id)
        expect(analysis.reload.ai_status).to eq("failed")
      end
    end

    context "when the song does not exist" do
      it "does not raise" do
        expect { described_class.new.perform(0) }.not_to raise_error
      end
    end
  end
end

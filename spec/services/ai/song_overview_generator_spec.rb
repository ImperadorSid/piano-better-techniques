require "rails_helper"

RSpec.describe AI::SongOverviewGenerator do
  let(:song) { create(:song, :with_analysis) }
  let(:generator) { described_class.new(song) }

  let(:api_response_body) do
    {
      "overview" => "Twinkle is a classic beginner piece.",
      "song_map" => "C major opening, F chord in the middle.",
      "hand_positions" => "Right hand plays melody. Left hand plays root notes.",
      "difficult_sections" => "The F chord transition can be tricky.",
      "harmony" => "Bright and cheerful due to the major key."
    }.to_json
  end

  let(:successful_response) do
    double(
      success?: true,
      body: { "content" => [ { "text" => api_response_body } ] }
    )
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

  describe "#generate!" do
    context "when the API responds successfully" do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(successful_response)
      end

      it "populates ai_overview on the song's analysis" do
        generator.generate!
        expect(song.song_analysis.reload.ai_overview).to eq("Twinkle is a classic beginner piece.")
      end

      it "populates ai_song_map" do
        generator.generate!
        expect(song.song_analysis.reload.ai_song_map).to eq("C major opening, F chord in the middle.")
      end

      it "populates ai_hand_positions" do
        generator.generate!
        expect(song.song_analysis.reload.ai_hand_positions).to include("Right hand")
      end

      it "populates ai_difficult_sections" do
        generator.generate!
        expect(song.song_analysis.reload.ai_difficult_sections).to eq("The F chord transition can be tricky.")
      end

      it "populates ai_harmony" do
        generator.generate!
        expect(song.song_analysis.reload.ai_harmony).to eq("Bright and cheerful due to the major key.")
      end
    end

    context "when ANTHROPIC_API_KEY is not set" do
      around do |example|
        original = ENV.delete("ANTHROPIC_API_KEY")
        example.run
        ENV["ANTHROPIC_API_KEY"] = original if original
      end

      it "does not call the API" do
        expect_any_instance_of(Faraday::Connection).not_to receive(:post)
        generator.generate!
      end

      it "leaves the analysis fields blank" do
        generator.generate!
        expect(song.song_analysis.reload.ai_overview).to be_nil
      end
    end

    context "when the API call fails" do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(failed_response)
      end

      it "does not raise an error" do
        expect { generator.generate! }.not_to raise_error
      end

      it "leaves ai_overview blank" do
        generator.generate!
        expect(song.song_analysis.reload.ai_overview).to be_nil
      end
    end

    context "when the API returns invalid JSON" do
      let(:bad_response) do
        double(success?: true, body: { "content" => [ { "text" => "not json at all" } ] })
      end

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(bad_response)
      end

      it "does not raise an error" do
        expect { generator.generate! }.not_to raise_error
      end
    end

    context "when the song has no analysis record" do
      let(:song_without_analysis) { create(:song) }
      let(:generator) { described_class.new(song_without_analysis) }

      it "does not raise an error" do
        expect { generator.generate! }.not_to raise_error
      end
    end
  end
end

require "rails_helper"

RSpec.describe AI::SongOverviewGenerator do
  let(:song) { create(:song, :with_analysis) }
  let(:generator) { described_class.new(song) }

  let(:structured_response) do
    {
      "overview" => {
        "mood" => "Cheerful and innocent",
        "key_insight" => "C major means mostly white keys",
        "tempo_insight" => "100 BPM is a comfortable walking pace",
        "time_insight" => "4/4 means count 1-2-3-4",
        "estimated_practice_time" => "2-3 hours",
        "key_takeaway" => "Simple repeating patterns make this easy to learn",
        "body" => "Twinkle is a classic beginner piece."
      },
      "song_map" => [
        { "section" => "A", "beats" => "0-16", "chords" => "C-F-G-C", "description" => "Main melody" }
      ],
      "hand_positions" => {
        "right" => { "position" => "C4-G4", "role" => "Melody", "drill" => "Finger Walking", "target_bpm" => 80 },
        "left" => { "position" => "C3-G3", "role" => "Bass notes", "drill" => "Root Note Hold", "target_bpm" => 60 },
        "coordination_tip" => "Left hand on beat 1, right hand plays melody"
      },
      "difficult_sections" => [
        { "name" => "Chord change", "beats" => "12-16", "challenge" => "Quick repositioning", "method" => "Slow Motion", "start_bpm" => 50, "milestone" => "3 times without mistakes" }
      ],
      "harmony" => {
        "chord_emotions" => [ { "chord" => "C", "emotion" => "Home and settled" } ],
        "dynamics_guidance" => "Play verses at medium volume."
      }
    }
  end

  let(:api_response_body) { structured_response.to_json }

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

      it "clears ai_status" do
        song.song_analysis.update!(ai_status: "pending")
        generator.generate!
        expect(song.song_analysis.reload.ai_status).to be_nil
      end

      it "stores ai_overview as JSON string" do
        generator.generate!
        overview = JSON.parse(song.song_analysis.reload.ai_overview)
        expect(overview["mood"]).to eq("Cheerful and innocent")
        expect(overview["estimated_practice_time"]).to eq("2-3 hours")
      end

      it "stores ai_song_map as JSON array string" do
        generator.generate!
        song_map = JSON.parse(song.song_analysis.reload.ai_song_map)
        expect(song_map).to be_an(Array)
        expect(song_map.first["section"]).to eq("A")
      end

      it "stores ai_hand_positions as JSON string with right/left" do
        generator.generate!
        hands = JSON.parse(song.song_analysis.reload.ai_hand_positions)
        expect(hands["right"]["role"]).to eq("Melody")
        expect(hands["left"]["drill"]).to eq("Root Note Hold")
      end

      it "stores ai_difficult_sections as JSON array string" do
        generator.generate!
        sections = JSON.parse(song.song_analysis.reload.ai_difficult_sections)
        expect(sections.first["method"]).to eq("Slow Motion")
      end

      it "stores ai_harmony as JSON string with chord_emotions" do
        generator.generate!
        harmony = JSON.parse(song.song_analysis.reload.ai_harmony)
        expect(harmony["chord_emotions"].first["chord"]).to eq("C")
        expect(harmony["dynamics_guidance"]).to include("medium volume")
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

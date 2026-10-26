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

  let(:successful_response) do
    double(
      success?: true,
      body: {
        "content" => [
          { "type" => "tool_use", "id" => "toolu_123", "name" => "song_analysis", "input" => structured_response }
        ],
        "usage" => { "input_tokens" => 500, "output_tokens" => 1200 }
      }
    )
  end

  let(:failed_response) do
    double(success?: false, status: 401, body: { "error" => { "type" => "authentication_error", "message" => "invalid x-api-key" } })
  end

  around do |example|
    original = ENV["ANTHROPIC_API_KEY"]
    ENV["ANTHROPIC_API_KEY"] = "test-key"
    example.run
    ENV["ANTHROPIC_API_KEY"] = original
  end

  describe "#generate!" do
    context "when the API responds successfully with tool_use" do
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

      it "logs token usage from the API response" do
        expect(Rails.logger).to receive(:info).with(/Token usage.*input=500.*output=1200/)
        generator.generate!
      end

      it "persists token usage to the analysis record" do
        generator.generate!
        analysis = song.song_analysis.reload
        expect(analysis.input_tokens).to eq(500)
        expect(analysis.output_tokens).to eq(1200)
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

      it "logs the HTTP status and API error" do
        expect(Rails.logger).to receive(:error).with(/request failed for song #{song.id}: status=401.*authentication_error.*invalid x-api-key/)
        generator.generate!
      end
    end

    context "when the API returns a non-JSON error body" do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post)
          .and_return(double(success?: false, status: 502, body: "Bad Gateway"))
      end

      it "logs the raw body without raising" do
        expect(Rails.logger).to receive(:error).with(/status=502, error=Bad Gateway/)
        expect { generator.generate! }.not_to raise_error
      end
    end

    context "when the response was truncated at max_tokens" do
      let(:truncated_response) do
        double(
          success?: true,
          body: {
            "stop_reason" => "max_tokens",
            "content" => [
              { "type" => "tool_use", "id" => "toolu_123", "name" => "song_analysis", "input" => structured_response.slice("overview") }
            ],
            "usage" => { "input_tokens" => 500, "output_tokens" => 16_000 }
          }
        )
      end

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(truncated_response)
      end

      it "does not store the partial tool input" do
        generator.generate!
        expect(song.song_analysis.reload.ai_overview).to be_nil
      end

      it "logs the truncation" do
        expect(Rails.logger).to receive(:error).with(/song #{song.id} was truncated at max_tokens/)
        generator.generate!
      end
    end

    context "when the API returns no tool_use block" do
      let(:no_tool_response) do
        double(
          success?: true,
          body: {
            "content" => [ { "type" => "text", "text" => "I cannot process this." } ],
            "usage" => { "input_tokens" => 100, "output_tokens" => 20 }
          }
        )
      end

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post).and_return(no_tool_response)
      end

      it "does not raise an error" do
        expect { generator.generate! }.not_to raise_error
      end

      it "leaves ai_overview blank" do
        generator.generate!
        expect(song.song_analysis.reload.ai_overview).to be_nil
      end
    end

    context "request sent to the API" do
      let(:request) do
        Faraday::Request.new(:post, nil, {}, Faraday::Utils::Headers.new, nil, Faraday::RequestOptions.new)
      end

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:post) do |_conn, &block|
          block.call(request)
          successful_response
        end
        generator.generate!
      end

      it "sends a valid anthropic-version header" do
        expect(request.headers["anthropic-version"]).to eq("2023-06-01")
      end

      it "opts into server-side refusal fallbacks" do
        expect(request.headers["anthropic-beta"]).to eq("server-side-fallback-2026-07-01")
        expect(request.body[:fallbacks]).to eq("default")
      end

      it "uses Claude Sonnet 5.5" do
        expect(request.body[:model]).to eq("claude-sonnet-5-5")
      end

      it "requests low effort to keep thinking costs down" do
        expect(request.body[:output_config]).to eq({ effort: "low" })
      end

      it "leaves room for thinking in max_tokens" do
        expect(request.body[:max_tokens]).to eq(16_000)
      end

      it "uses auto tool_choice, since forced tool use is rejected by the model" do
        expect(request.body[:tool_choice]).to eq({ type: "auto" })
      end

      it "defines the song_analysis tool as strict" do
        tool = request.body[:tools].first
        expect(tool[:name]).to eq("song_analysis")
        expect(tool[:strict]).to be(true)
      end

      it "disallows additional properties on every object in the tool schema" do
        objects = []
        collect = lambda do |node|
          case node
          when Hash
            objects << node if node[:type] == "object"
            node.each_value { |v| collect.call(v) }
          when Array
            node.each { |v| collect.call(v) }
          end
        end
        collect.call(request.body[:tools].first[:input_schema])

        expect(objects.size).to eq(9)
        expect(objects).to all(include(additionalProperties: false))
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

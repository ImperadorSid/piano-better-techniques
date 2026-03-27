require "rails_helper"

RSpec.describe "Songs", type: :request do
  let!(:song) { create(:song, :with_part, :with_analysis) }

  describe "GET /songs" do
    it "returns http success" do
      get songs_path
      expect(response).to have_http_status(:success)
    end

    it "only shows ready songs" do
      pending_song = create(:song, import_status: "pending", title: "Pending Song")
      get songs_path
      expect(response.body).not_to include("Pending Song")
    end
  end

  describe "GET /songs/:id" do
    it "returns http success" do
      get song_path(song)
      expect(response).to have_http_status(:success)
    end

    it "shows song title" do
      get song_path(song)
      expect(response.body).to include(song.title)
    end
  end

  describe "GET /songs/:id/analyze" do
    context "when song has no analysis" do
      let(:song_without_analysis) { create(:song, :with_part) }

      it "returns http success" do
        get analyze_song_path(song_without_analysis)
        expect(response).to have_http_status(:success)
      end

      it "shows 'no analysis' message" do
        get analyze_song_path(song_without_analysis)
        expect(response.body).to include("No analysis available for this song yet.")
      end

      it "does not show the regenerate button" do
        get analyze_song_path(song_without_analysis)
        expect(response.body).not_to include("Regenerate Analysis")
      end

      it "does not show the loading banner" do
        get analyze_song_path(song_without_analysis)
        expect(response.body).not_to include("Generating AI analysis")
      end
    end

    context "when analysis exists with no AI content (fresh)" do
      it "enqueues the overview job" do
        expect {
          get analyze_song_path(song)
        }.to have_enqueued_job(SongOverviewJob).with(song.id)
      end

      it "shows the loading banner" do
        get analyze_song_path(song)
        expect(response.body).to include("Generating AI analysis")
      end

      it "does not show the regenerate button" do
        get analyze_song_path(song)
        expect(response.body).not_to include("Regenerate Analysis")
      end

      it "does not show the error banner" do
        get analyze_song_path(song)
        expect(response.body).not_to include("AI analysis could not be completed")
      end
    end

    context "when AI analysis is already generated" do
      before do
        song.song_analysis.update!(
          ai_overview: "Test overview",
          ai_song_map: "Test song map",
          ai_hand_positions: "Test hand positions",
          ai_difficult_sections: "Test difficult sections",
          ai_harmony: "Test harmony"
        )
      end

      it "does not enqueue another job" do
        expect {
          get analyze_song_path(song)
        }.not_to have_enqueued_job(SongOverviewJob)
      end

      it "shows the regenerate button" do
        get analyze_song_path(song)
        expect(response.body).to include("REGENERATE")
      end

      it "shows the AI content sections" do
        get analyze_song_path(song)
        expect(response.body).to include("Test overview")
        expect(response.body).to include("Test song map")
        expect(response.body).to include("Test hand positions")
        expect(response.body).to include("Test difficult sections")
        expect(response.body).to include("Test harmony")
      end

      it "does not show the loading banner" do
        get analyze_song_path(song)
        expect(response.body).not_to include("Generating AI analysis")
      end

      it "does not show the error banner" do
        get analyze_song_path(song)
        expect(response.body).not_to include("AI analysis could not be completed")
      end
    end

    context "when AI analysis is pending" do
      before { song.song_analysis.update!(ai_status: "pending") }

      it "does not enqueue another job" do
        expect {
          get analyze_song_path(song)
        }.not_to have_enqueued_job(SongOverviewJob)
      end

      it "shows the loading banner" do
        get analyze_song_path(song)
        expect(response.body).to include("Generating AI analysis")
      end

      it "does not show the regenerate button" do
        get analyze_song_path(song)
        expect(response.body).not_to include("Regenerate Analysis")
      end
    end

    context "when AI analysis has failed" do
      before { song.song_analysis.update!(ai_status: "failed") }

      it "does not enqueue a job on page load" do
        expect {
          get analyze_song_path(song)
        }.not_to have_enqueued_job(SongOverviewJob)
      end

      it "shows the error banner" do
        get analyze_song_path(song)
        expect(response.body).to include("AI analysis could not be completed")
      end

      it "does not show the loading banner" do
        get analyze_song_path(song)
        expect(response.body).not_to include("Generating AI analysis")
      end

      it "does not show the regenerate button" do
        get analyze_song_path(song)
        expect(response.body).not_to include("Regenerate Analysis")
      end
    end
  end

  describe "POST /songs/:id/regenerate" do
    context "when AI analysis is already generated" do
      before do
        song.song_analysis.update!(
          ai_overview: "Old overview",
          ai_song_map: "Old map",
          ai_hand_positions: "Old positions",
          ai_difficult_sections: "Old sections",
          ai_harmony: "Old harmony"
        )
      end

      it "enqueues the overview job" do
        expect {
          post regenerate_song_path(song)
        }.to have_enqueued_job(SongOverviewJob).with(song.id)
      end

      it "clears existing AI fields" do
        post regenerate_song_path(song)
        analysis = song.song_analysis.reload
        expect(analysis.ai_overview).to be_nil
        expect(analysis.ai_song_map).to be_nil
        expect(analysis.ai_hand_positions).to be_nil
        expect(analysis.ai_difficult_sections).to be_nil
        expect(analysis.ai_harmony).to be_nil
      end

      it "sets status to pending" do
        post regenerate_song_path(song)
        expect(song.song_analysis.reload.ai_status).to eq("pending")
      end

      it "redirects to the analyze page" do
        post regenerate_song_path(song)
        expect(response).to redirect_to(analyze_song_path(song))
      end
    end

    context "when AI analysis has failed" do
      before { song.song_analysis.update!(ai_status: "failed") }

      it "enqueues the overview job" do
        expect {
          post regenerate_song_path(song)
        }.to have_enqueued_job(SongOverviewJob).with(song.id)
      end

      it "sets status to pending" do
        post regenerate_song_path(song)
        expect(song.song_analysis.reload.ai_status).to eq("pending")
      end
    end

    context "when AI analysis is already pending" do
      before { song.song_analysis.update!(ai_status: "pending") }

      it "does not enqueue another job" do
        expect {
          post regenerate_song_path(song)
        }.not_to have_enqueued_job(SongOverviewJob)
      end

      it "redirects to the analyze page" do
        post regenerate_song_path(song)
        expect(response).to redirect_to(analyze_song_path(song))
      end
    end
  end

  describe "DELETE /songs/:id" do
    it "deletes the song and redirects" do
      expect {
        delete song_path(song)
      }.to change(Song, :count).by(-1)
      expect(response).to redirect_to(songs_path)
    end
  end
end

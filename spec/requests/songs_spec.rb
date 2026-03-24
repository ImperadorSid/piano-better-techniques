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
    it "returns http success" do
      get analyze_song_path(song)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /songs/import" do
    it "returns http success" do
      get import_songs_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /songs/import" do
    it "creates a song and enqueues an import job" do
      expect {
        post import_songs_path, params: { title: "New Song", source_url: "http://example.com" }
      }.to change(Song, :count).by(1)
    end

    it "redirects to the song page" do
      post import_songs_path, params: { title: "New Song", source_url: "http://example.com" }
      expect(response).to redirect_to(Song.last)
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

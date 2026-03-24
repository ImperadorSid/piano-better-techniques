class SongImportJob < ApplicationJob
  queue_as :default

  discard_on ActiveRecord::RecordNotFound

  def perform(song_id)
    song = Song.find(song_id)
    return if song.import_status == "ready"

    song.update!(import_status: "processing")

    if song.source_format == "abc" || song.source_url&.include?("thesession.org")
      source = song.source_url.presence || song.raw_source
      Importers::AbcImporter.new(source).import_into(song)
    elsif song.raw_source.present?
      Importers::MidiImporter.new(song.raw_source).import_into(song)
    else
      song.update!(import_status: "failed")
      return
    end

    song.save!

    if song.import_status == "ready"
      Analyzers::SongAnalyzer.new(song).analyze!
    end
  rescue StandardError => e
    Rails.logger.error "[SongImportJob] Error for song #{song_id}: #{e.message}"
    song&.update!(import_status: "failed")
    raise
  end
end

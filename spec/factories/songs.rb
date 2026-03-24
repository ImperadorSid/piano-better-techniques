FactoryBot.define do
  factory :song do
    title { Faker::Music.band }
    composer { Faker::Name.name }
    difficulty { 1 }
    tempo_bpm { 120 }
    time_signature { "4/4" }
    key_signature { "C" }
    import_status { "ready" }
    source_format { "manual" }

    trait :pending do
      import_status { "pending" }
    end

    trait :failed do
      import_status { "failed" }
    end

    trait :with_part do
      after(:create) do |song|
        create(:song_part, song: song)
      end
    end

    trait :with_analysis do
      after(:create) do |song|
        create(:song_analysis, song: song)
      end
    end
  end
end

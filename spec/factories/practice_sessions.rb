FactoryBot.define do
  factory :practice_session do
    song
    song_part
    started_at { Time.current }
    total_notes { 3 }
    correct_notes { 0 }
    incorrect_notes { 0 }
    completed { false }
    notes_reached { 0 }

    trait :completed do
      completed { true }
      ended_at { Time.current }
      correct_notes { 3 }
      incorrect_notes { 0 }
      accuracy_pct { 100.0 }
      notes_reached { 3 }
    end
  end
end

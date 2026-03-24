FactoryBot.define do
  factory :session_attempt do
    practice_session
    note_position { 0 }
    expected_midi { 60 }
    played_midi { 60 }
    correct { true }
    response_ms { 350 }

    trait :incorrect do
      played_midi { 62 }
      correct { false }
    end
  end
end

FactoryBot.define do
  factory :conversation do
    trait :between do
      transient do
        user_a { nil }
        user_b { nil }
      end

      after(:create) do |convo, eval|
        convo.conversation_participants.create!(user: eval.user_a)
        convo.conversation_participants.create!(user: eval.user_b)
      end
    end
  end
end

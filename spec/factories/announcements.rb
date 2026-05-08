FactoryBot.define do
  factory :announcement do
    title { Faker::Lorem.sentence(word_count: 4) }
    body  { Faker::Lorem.paragraphs(number: 2).join("\n\n") }
    association :user
  end
end

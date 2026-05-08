FactoryBot.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.unique.email }
    password   { "password123" }
    role       { "parent" }
    admin      { false }

    trait :teacher do
      role { "teacher" }
    end

    trait :student do
      role { "student" }
    end

    trait :admin do
      admin { true }
    end
  end
end

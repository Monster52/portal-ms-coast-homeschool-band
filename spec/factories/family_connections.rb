FactoryBot.define do
  factory :family_connection do
    association :parent, factory: :user, role: "parent"
    association :student, factory: :user, role: "student"
    confirmed { false }

    trait :confirmed do
      confirmed { true }
    end
  end
end

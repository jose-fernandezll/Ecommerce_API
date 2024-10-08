FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
    role { 'user' }

    trait :admin do
      role { 'admin' }
    end
  end
end

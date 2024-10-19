FactoryBot.define do
  factory :payment do
    order { nil }
    stripe_id { "MyString" }
  end
end

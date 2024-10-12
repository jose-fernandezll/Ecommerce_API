FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    price { Faker::Commerce.price(range: 10.0..100.0) }
    stock { Faker::Number.between(from: 6, to: 100) }
  end
end

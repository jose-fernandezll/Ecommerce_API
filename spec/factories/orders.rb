# spec/factories/orders.rb
FactoryBot.define do
  factory :order do
    association :user
    after(:create) do |order, evaluator|
      create_list(:order_item, 3, order: order)
    end
  end
end

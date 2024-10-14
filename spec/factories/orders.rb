# spec/factories/orders.rb
FactoryBot.define do
  factory :order do
    association :user

    transient do
      items_count { 3 }
    end

    after(:create) do |order, evaluator|
      create_list(:order_item, evaluator.items_count, order: order)
    end
  end
end

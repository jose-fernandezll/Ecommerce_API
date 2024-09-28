require 'rails_helper'

RSpec.describe "Carts", type: :request do
  include_context :login_user

  describe "GET" do
    it '/carts' do
      get cart_url
      expect(response).to be_successful
    end
  end

  describe "POST" do
    let(:product) { create(:product) }

    it '/cart/add_item' do
      post add_item_cart_url, params: { product_id: product.id }

      expect(response).to be_successful
    end
  end

  describe "DELETE" do
    let(:product) { create(:product) }
    it 'cart/remove_item/' do
      user.cart.products.append(product)

      delete remove_item_cart_url, params: { product_id: product.id }

      expect(response).to be_successful
    end

    it 'cart/remove_item/' do
      delete remove_item_cart_url, params: { product_id: product.id }

      binding.irb

      expect(response.data.error).to eq("Item not found in cart")
    end
  end
end

require 'rails_helper'

RSpec.describe "Carts", type: :request do
  include_context :login_user

  context 'GET' do
    describe "/cart" do
      it 'should have a http status code :ok' do
        get cart_url
        expect(response).to be_successful
      end
    end
  end

  context 'POST' do
    describe "/cart/add_item" do
      let(:product) { create(:product) }

      it 'should have a http status code :ok' do
        post add_item_cart_url, params: { product_id: product.id }
        expect(response).to be_successful
      end
      # deberia haber mas test para comprobar que si se agrega el producto
    end
  end

  context 'DELETE' do
    describe "cart/remove_item/:id" do
      let(:product) { create(:product) }

      it 'should have a http status code :ok' do
        user.cart.products.append(product)

        delete remove_item_cart_url, params: { product_id: product.id }

        expect(response).to be_successful
      end

      it 'should not found the item in the car' do
        delete remove_item_cart_url, params: { product_id: product.id }

        expect(json_body['error']).to eq("Item not found in cart")
      end

      # deberia haber mas test para comprobar que si se elimina el producto

    end
  end
end

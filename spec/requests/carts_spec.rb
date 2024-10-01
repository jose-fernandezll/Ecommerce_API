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
      subject { post add_item_cart_url, params: { product_id: product_id } }

      describe 'valid when' do
        let(:product_id) { product.id }

        before { subject }

        it 'have a http status code :ok' do
          expect(response).to be_successful
        end

        it 'has a product in the car' do
          subject
          expect(current_user.cart.products.count).to eq(1)
        end

        it 'the product in the cart should match product' do
          expect(current_user.cart.products.first).to eq(product)
        end
      end

      describe 'invalid when' do
        let(:product_id) { 9999 }

        it 'the product dont exist' do
          subject
          expect(json_body['error']).to eq('Product not found.')
        end
      end

    end
  end

  context 'DELETE' do
    let(:product) { create(:product) }
    let(:product_2) { create(:product) }

    subject { delete remove_item_cart_url, params: { product_id: product_id } }

    describe "cart/remove_item/:id" do
      let(:product_id) { product.id }

      before do
        current_user.cart.products.append(product)
        current_user.cart.products.append(product_2) if defined?(product_2)
      end

      describe 'valid when' do
        it 'have a http status code :ok' do
          subject
          expect(response).to be_successful
        end

        it 'removes the product from the cart' do
          subject
          expect(current_user.cart.products.count).to eq(1)
        end

        it 'keeps only the remaining product in the cart' do
          subject
          expect(json_body['cart_items'].count).to eq(1)
          expect(json_body['cart_items'][0]['product_id']).to eq(product_2.id)
        end

      end

      describe 'invalid when' do
        let(:product_id) { 9999 }

        it 'not found the item in the car' do
          subject
          expect(json_body['error']).to eq("CartItem not found.")
        end

        describe 'logout user' do
          include_context :logout_user

          it 'when the user is logged out' do
            subject
            expect(response.body).to eq('You need to sign in or sign up before continuing.')
          end
        end
      end
    end
  end
end

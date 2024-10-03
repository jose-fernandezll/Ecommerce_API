require 'rails_helper'

RSpec.describe "Carts", type: :request do
  include_context :login_user

  context 'GET' do
    subject { get cart_url }
    let!(:product_1) { create(:product) }
    let!(:product_2) { create(:product) }

    describe "/cart" do
      it 'should return a HTTP status code :ok' do
        subject
        expect(response).to be_successful
      end

      before do
        current_user.cart.products.append(product_1)
        current_user.cart.products.append(product_2) if defined?(product_2)
      end

      it 'should match the current user\'s cart' do
        subject
        expect(json_body['data']).to eq(serialized_body('CartSerializer', current_user.cart)['data'])
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

        it 'returns a HTTP status code :ok' do
          expect(response).to be_successful
        end

        it 'add a product to the car' do
          subject
          expect(current_user.cart.products.count).to eq(1)
        end

        it 'matches the added product in the cart' do
          expect(current_user.cart.products.first).to eq(product)
        end
      end

      describe 'invalid when' do
        let(:product_id) { 9999 }

        it 'returns an error when the product does not exist' do
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
        it 'returns a HTTP status code :ok' do
          subject
          expect(response).to be_successful
        end

        it 'removes the product from the cart' do
          subject
          expect(current_user.cart.products.count).to eq(1)
        end

        it 'keeps only the remaining product in the cart' do
          subject
          expect(json_body['data']['relationships']['cart_items'].count).to eq(1)

          expect(
            json_body['included'][0]['relationships']['product']['data']['id']
          ).to eq(product_2.id.to_s)
        end

      end

      describe 'invalid when' do
        let(:product_id) { 9999 }

        it 'returns an error when the item is not found in the cart' do
          subject
          expect(json_body['error']).to eq("CartItem not found.")
        end

        describe 'logout user' do
          include_context :logout_user

          it 'returns an error when the user is logged out' do
            subject
            expect(response.body).to eq('You need to sign in or sign up before continuing.')
          end
        end
      end
    end
  end
end

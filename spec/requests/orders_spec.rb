require 'rails_helper'

RSpec.describe "Orders", type: :request do
  include_context :login_user, admin: true

  context "POST" do

    subject(:post_order) { post api_v1_orders_path, headers: headers, params: { data: { card_token: 'tok_visa' } } }
    let!(:product_1) { create(:product, stock: 10) }
    let!(:product_2) { create(:product, stock: 20) }

    describe 'valid context' do
      before do
        post add_item_api_v1_cart_path, params: { product_id: product_1.id, quantity: 2 }, headers: headers
        post add_item_api_v1_cart_path, params: { product_id: product_2.id, quantity: 3 }, headers: headers
      end

      it 'returns a HTTP status code: created' do
        post_order
        expect(response).to have_http_status(:created)
      end

      it 'returns the order in json format' do
        post_order
        expect(json_body['order']['data']).to eq(serialized_body('OrderSerializer', current_user.orders.first)['data'])
        expect(current_user.cart.cart_items).to eq([])
      end

      it 'creates a payment for the order' do
        post_order
        expect(current_user.orders.first.payment).not_to be_nil
      end
    end

    describe 'invalid context' do

      describe 'returns validation error when order is invalid' do
        let(:order) { build(:order, user: current_user) }

        before do
          post add_item_api_v1_cart_path, params: { product_id: product_1.id, quantity: 2 }, headers: headers
          post add_item_api_v1_cart_path, params: { product_id: product_2.id, quantity: 3 }, headers: headers
        end

        before do
          allow_any_instance_of(Order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(order))
        end

        it 'returns validation error when order cannot be saved' do
          post_order

          expect(json_body).to eq({"error"=>"Validation failed: "})
        end
      end

      it 'returns a HTTP status code: unprocessable_entity when cart is empty' do
        post_order

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an error message when cart is empty' do
        post_order

        expect(json_body).to eq({ 'error'=>'Cart is empty' })
      end
    end
  end

  context "GET" do
    let!(:order) { create(:order, user: current_user) }
    subject(:get_order) { get api_v1_orders_path, params:{ id: order.id } , headers: headers }
    describe 'valid context' do
      it 'returns a HTTP status code: ok' do
        get_order
        expect(response).to have_http_status(:ok)
      end
      
      it 'returns the order data in json format' do
        get_order
        expect(json_body['data']).to eq(serialized_body('OrderSerializer',current_user.orders.first)['data'])
      end
    end

    describe 'invalid context' do
      subject(:get_order) { get api_v1_orders_path, params:{ id: 9999 } , headers: headers }
      it 'returns a HTTP status code :not_found' do
        get_order
        expect(response).to have_http_status(:not_found)
      end
    end
  end

end

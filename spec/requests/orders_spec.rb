require 'rails_helper'

RSpec.describe "Orders", type: :request do
  include_context :login_user, admin: true

  context "POST" do

    subject(:post_order) { post orders_url, headers: headers }
    let!(:product_1) { create(:product, stock: 10) }
    let!(:product_2) { create(:product, stock: 20) }

    describe 'valid context' do
      before do
        post add_item_cart_url, params: { product_id: product_1.id, quantity: 2 }, headers: headers
        post add_item_cart_url, params: { product_id: product_2.id, quantity: 3 }, headers: headers
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
    end

    describe 'invalid context' do

      describe 'returns validation error when order is invalid' do
        let(:order) { build(:order, user: current_user) }

        before do
          post add_item_cart_url, params: { product_id: product_1.id, quantity: 2 }, headers: headers
          post add_item_cart_url, params: { product_id: product_2.id, quantity: 3 }, headers: headers
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

    subject(:get_order) { get orders_url, params:{ id: order.id } , headers: headers }

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
      subject(:get_order) { get orders_url, params:{ id: 9999 } , headers: headers }

      it 'returns a HTTP status code :not_found' do
        get_order
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  context 'PUT' do
    let!(:order) { create(:order, user: current_user, items_count: 1) }
    let!(:product) { create(:product) }
    let(:items){[
      { product_id: order.order_items[0].product.id, quantity: 0 },
      { product_id: product.id, quantity: 5 }
    ]}
    subject(:update_order){
      put orders_url,
      params:{
        id: order.id,
        order:{
          order_items: items
        }
      }, headers: headers
    }
    describe 'valid context' do

      it 'returns a HTTP status code :ok' do
        update_order
        expect(response).to have_http_status(:ok)
      end

      it 'returns the updated order data in JSON format' do
        update_order
        expect(json_body['included'][0]['relationships']['product']['data']['id']).to eq("#{product.id}")
        expect(json_body['data']).to eq(serialized_body('OrderSerializer',current_user.orders.first)['data'])
      end
    end

    describe 'invalid context' do
      let(:items){[
        { product_id: product.id, quantity: 999 }
      ]}

      it 'returns an error message for insufficient stock' do
        update_order
        expect(json_body['error']).to eq("Insufficient stock for product #{product.name}")
      end


      describe 'when the product does not exist' do
        let(:items){[
          { product_id: 999, quantity: 2 }
        ]}

        it 'returns a HTTP status code :not_found' do
          update_order
          expect(json_body['message']).to eq("Couldn't find Product")
        end
      end

      describe 'when required parameter is missing' do
        subject(:update_order){
          put orders_url,
          params:{
            id: order.id
          }, headers: headers
        }

        it 'returns an error message for missing parameter' do
          update_order
          expect(response).to have_http_status(:bad_request)
          expect(json_body['error']).to eq("Required parameter missing: order")
        end
      end
    end
  end
end

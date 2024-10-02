require 'rails_helper'

RSpec.describe "Carts", type: :request do
  include_context :login_user, admin: true
  #include_context :login_user
  context 'GET' do
    let!(:product_1) { create(:product) }
    let!(:product_2) { create(:product) }

    subject { get products_url }

    describe '/products' do
      it 'should have a http status code :ok' do
        subject
        expect(response).to be_successful
      end

      it 'should be return 2 products' do
        subject
        expect(json_body.count).to eq(2)
      end

      it 'should be match product 1 and 2' do
        products = []
        products.append(JSON.parse(product_1.to_json))
        products.append(JSON.parse(product_2.to_json))

        subject

        expect(json_body).to eq(products)
      end
    end

    describe '/products/:id' do
      subject { get products_url(product) }

      describe 'valid context' do
        let(:product){ product_1}
        it 'should have a http status code :ok' do
          subject
          expect(response).to be_successful
        end

        it 'should be match product 1' do
          product = JSON.parse(product_1.to_json)
          subject
          expect(json_body.first).to eq(product)
        end
      end

      describe 'invalid context' do
        let(:invalid_product_id) { 9999 }
        subject { get product_url(invalid_product_id) }

        it 'when the product doesnt exist' do
          subject
          expect(json_body['error']).to eq('Product not found.')
        end
      end
    end
  end

  context 'POST' do
    subject{ post products_url, params: { product: product }}

    let(:valid_product){
      {
        name:'bottle of water',
        description:'this is a short description about what is a bottle of water',
        price: 3.99,
        stock:10000
      }
    }
    let(:invalid_product){
      {
        name:'bottle of water',
        description:'this is a short description about what is a bottle of water',
        price: -1,
        stock:-1
      }
    }

    describe '/products' do
      let(:product) { valid_product }

      it 'should create the product' do
        subject
        expect(response).to be_successful
      end
    end
  end

end

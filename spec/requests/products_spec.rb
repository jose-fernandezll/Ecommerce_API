require 'rails_helper'

RSpec.describe "Carts", type: :request do
  include_context :login_user

  context 'GET' do
    let!(:product_1) { create(:product) }
    let!(:product_2) { create(:product) }

    describe '/products' do
      it 'should have a http status code :ok' do
        get products_url
        expect(response).to be_successful
      end

      it 'should be return 2 products' do
        get products_url
        expect(json_body.count).to eq(2)
      end

      it 'should be match product 1 and 2' do
        products = []
        products.append(JSON.parse(product_1.to_json))
        products.append(JSON.parse(product_2.to_json))

        get products_url

        expect(json_body).to eq(products)
      end
    end

    describe '/products/:id' do
      it 'should have a http status code :ok' do
        get product_url(product_1)

        expect(response).to be_successful
      end

      it 'should be match product 1' do
        product = JSON.parse(product_1.to_json)
        get product_url(product_1)

        expect(json_body).to eq(product)
      end
    end
  end

end

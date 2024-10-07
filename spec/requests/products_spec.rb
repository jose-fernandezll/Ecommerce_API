require 'rails_helper'

RSpec.describe "Products", type: :request do
  include_context :login_user, admin: true

  context 'GET' do
    let!(:product_1) { create(:product) }
    let!(:product_2) { create(:product) }

    subject(:get_index){ get products_url, headers: headers  }

    describe '/products' do
      it 'should return a HTTP status code :ok' do
        get_index
        expect(response).to be_successful
      end

      it 'should return 2 products' do
        get_index
        expect(json_body['data'].count).to eq(2)
      end

      it 'should match product 1 and 2' do
        products = []
        products.append(JSON.parse(product_1.to_json))
        products.append(JSON.parse(product_2.to_json))

        get_index
        expect(json_body['data']).to eq(serialized_body('ProductSerializer', Product.all)['data'])
      end
    end

    describe '/products/:id' do
      subject(:show_product) { get product_url(product), headers: headers  }

      describe 'valid context' do
        let(:product){ product_1}

        it 'should return a HTTP status code :ok' do
          show_product
          expect(response).to be_successful
        end

        it 'should match product 1' do
          show_product

          expect(json_body['data']).to eq(serialized_body('ProductSerializer', product_1)['data'])
        end
      end

      describe 'invalid context' do
        let(:invalid_product_id) { 9999 }
        subject(:show_product) { get product_url(invalid_product_id), headers: headers  }

        it 'when the product doesnt exist' do
          show_product

          expect(json_body['message']).to eq("Couldn't find Product")
        end
      end
    end
  end

  context 'POST' do
    subject(:post_product){ post products_url, params: { product: product }, headers: headers }

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

      describe 'valid' do
        it 'should return a HTTP status code :ok' do
          post_product
          expect(response).to be_successful
        end

        it 'should create the product' do
          post_product
          expect(json_body['data']).to eq(serialized_body('ProductSerializer', Product.first)['data'])
        end
      end

      describe 'invalid' do
        let(:product) { invalid_product }

        it 'should return a HTTP status code :unprocessable_entity' do
          post_product
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return render errors' do
          post_product
          expect(json_body['errors']).to eq({"price"=>["must be greater than or equal to 0"], "stock"=>["must be greater than or equal to 0"]})
        end


        it 'should return render errors' do
          invalid_product[:name] = ''
          invalid_product[:description] = ''

          post_product

          expect(json_body['errors']).to eq({
            "description"=>["can't be blank"], "name"=>["can't be blank"],
            "price"=>["must be greater than or equal to 0"], "stock"=>["must be greater than or equal to 0"]
          })
        end
        # render forbidden

        describe 'logout user' do
          include_context :login_user, admin: false

          it 'returns a forbidden status' do
            post products_url, params: { product: valid_product }, headers: headers
            expect(response).to have_http_status(:forbidden)
            expect(response.body).to include('You are not authorized to perform this action.')
          end
        end
      end
    end
  end

end

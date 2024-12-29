require 'rails_helper'

RSpec.describe "Products", type: :request do
  include_context :login_user, admin: true

  context 'GET' do
    let!(:product_1) { create(:product) }
    let!(:product_2) { create(:product) }

    subject(:get_index){ get api_v1_products_path, headers: headers  }

    describe '/products' do
      it 'returns a HTTP status code :ok' do
        get_index
        expect(response).to be_successful
      end

      it 'returns 2 products' do
        get_index
        expect(json_body['data'].count).to eq(2)
      end

      it 'matches product 1 and 2' do
        products = []
        products.append(JSON.parse(product_1.to_json))
        products.append(JSON.parse(product_2.to_json))

        get_index
        expect(json_body['data']).to eq(serialized_body('ProductSerializer', Product.all)['data'])
      end
    end

    describe '/products/:id' do
      subject(:show_product) { get api_v1_product_path(product), headers: headers  }

      describe 'valid context' do
        let(:product){ product_1}

        it 'returns a HTTP status code :ok' do
          show_product
          expect(response).to be_successful
        end

        it 'matches product 1' do
          show_product

          expect(json_body['data']).to eq(serialized_body('ProductSerializer', product_1)['data'])
        end
      end

      describe 'invalid context' do
        let(:invalid_product_id) { 9999 }
        subject(:show_product) { get api_v1_product_path(invalid_product_id), headers: headers  }

        it 'returns an error when the product does not exist' do
          show_product

          expect(json_body['message']).to eq("Couldn't find Product")
        end
      end
    end
  end

  context 'POST' do
    subject(:post_product){ post api_v1_products_path, params: { product: product }, headers: headers }

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

      describe 'valid context' do
        it 'returns a HTTP status code :ok' do
          post_product
          expect(response).to be_successful
        end

        it 'creates the product' do
          post_product
          expect(json_body['data']).to eq(serialized_body('ProductSerializer', Product.first)['data'])
        end
      end

      describe 'invalid context' do
        let(:product) { invalid_product }

        it 'returns a HTTP status code :unprocessable_entity' do
          post_product
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders validation errors' do
          post_product
          expect(json_body['errors']).to eq({
            "price"=>["must be greater than or equal to 0"],
            "stock"=>["must be greater than or equal to 0"]
          })
        end


        it 'renders additional validation errors when name and description are blank' do
          invalid_product[:name] = ''
          invalid_product[:description] = ''

          post_product

          expect(json_body['errors']).to eq({
            "description"=>["can't be blank"], "name"=>["can't be blank"],
            "price"=>["must be greater than or equal to 0"], "stock"=>["must be greater than or equal to 0"]
          })
        end

        describe 'when params are missing' do
          let(:product) { {} }

          it 'returns a HTTP status code :bad_request' do
            post_product
            expect(response).to have_http_status(:bad_request)
          end

          it 'returns an error message for missing parameters' do
            post_product
            expect(json_body).to eq({"error"=>"Required parameter missing: product"})
          end
        end

        describe 'when the user is not an admin' do
          include_context :login_user, admin: false

          it 'returns a forbidden status' do
            post api_v1_products_path, params: { product: valid_product }, headers: headers
            expect(response).to have_http_status(:forbidden)
            expect(response.body).to include('You are not authorized to perform this action.')
          end
        end
      end
    end
  end

  context 'UPDATE' do
    subject(:update_product){ put api_v1_product_path(product), params: { product: product_params }, headers: headers }
    let!(:product){ create(:product) }
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
    describe '/product/:id' do
      describe 'valid context' do
        let(:product_params){ valid_product }
        it 'returns a HTTP status code :ok' do
          update_product
          expect(response).to be_successful
        end

        it 'updates the product' do
          update_product
          expect(json_body['data']).to eq(serialized_body('ProductSerializer', Product.first)['data'])
        end
      end

      describe 'invalid context' do
        let(:product_params){ invalid_product }
        it 'returns a HTTP status code :unprocessable_entity' do
          update_product
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'renders validation errors' do
          update_product
          expect(json_body).to eq({"errors"=>{"price"=>["must be greater than or equal to 0"], "stock"=>["must be greater than or equal to 0"]}})
        end

        describe 'when the product does not exist' do
          let(:product){ 999 }

          it 'returns a HTTP status code :not_found' do
            update_product
            expect(response).to have_http_status(:not_found)
          end

          it 'renders a product not found message' do
            update_product
            expect(json_body).to eq({
              "message"=>"Couldn't find Product",
              "type"=>"ActiveRecord::RecordNotFound",
              "model"=>"Product"
            })
          end

        end
        describe 'when params are missing' do
          let(:product_params){ {} }

          it 'returns a HTTP status code :bad_request' do
            update_product
            expect(response).to have_http_status(:bad_request)
          end

          it 'returns an error message for missing parameters' do
            update_product
            expect(json_body).to eq({"error"=>"Required parameter missing: product"})
          end
        end

        describe 'when the user is not an admin' do
          include_context :login_user, admin: false

          it 'returns a forbidden status' do
            put api_v1_product_path(product), params: { product: valid_product }, headers: headers
            expect(response).to have_http_status(:forbidden)
            expect(response.body).to include('You are not authorized to perform this action.')
          end
        end

      end
    end
  end

  context 'DESTROY' do
    subject(:destroy_product){ delete api_v1_product_path(product), headers: headers}

    let!(:product_1){ create(:product) }
    let!(:product_2){ create(:product) }
    describe '/product/:id' do
      describe 'context valid' do
        let(:product){ product_1 }

        it 'returns a HTTP status code :no_content' do
          destroy_product
          expect(response).to have_http_status(:no_content)
        end

        it 'does not return any content in the response body' do
          destroy_product
          expect(response.body).to be_empty
        end

        it "decrease the count of product" do
          expect {
            destroy_product
          }.to change(Product, :count).by(-1)
        end
      end

      context 'invalid context' do
        describe 'when the product does not exist' do
          let(:product){ 999 }

          it 'renders a product not found message' do
            destroy_product
            expect(json_body).to eq({
              "message"=>"Couldn't find Product",
              "type"=>"ActiveRecord::RecordNotFound",
              "model"=>"Product"
            })
          end

          it 'returns a HTTP status code :not_found' do
            destroy_product
            expect(response).to have_http_status(:not_found)
          end
        end

        describe 'when destroy fails' do
          let(:product){ product_1 }

          before do
            # Mocking el método destroy para que falle (retorne false)
            allow_any_instance_of(Product).to receive(:destroy).and_return(false)
          end

          it 'returns a HTTP status code :unprocessable_entity' do
            destroy_product
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'returns an error message' do
            destroy_product
            expect(json_body['error']).to eq("Failed to delete product")
          end
        end
      end

    end
  end
end

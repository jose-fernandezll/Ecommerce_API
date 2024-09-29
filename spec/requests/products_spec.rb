require 'rails_helper'

RSpec.describe "Carts", type: :request do
  include_context :login_user

  context 'GET' do
    let!(:product_1) { create(:product) }
    let!(:product_2) { create(:product) }

    describe '/products' do
      it '' do
        get products_url

        binding.irb
        expect(response).to be_successful
      end
    end

    describe '/products/' do
      it '' do

      end
    end
  end

end

require 'rails_helper'

RSpec.describe "Carts", type: :request do
  include_context :login_user

  describe "GET" do
    it '/carts' do
      get cart_url
      expect(response).to be_successful
    end
  end
end

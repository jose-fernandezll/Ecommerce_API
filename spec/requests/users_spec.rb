require 'rails_helper'

RSpec.describe "Users", type: :request do

  context 'POST' do
    subject(:post_user){ post user_registration_path, params: { user: user_params } }

    let(:valid_user) {{
      email: 'jose@gmail.com',
      password: 'secure_password',
      name: 'jose',
      role: 'user'
    }}

    let(:invalid_user) {{
      name: 'jose',
      role: 'user'
    }}

    describe 'valid context' do
      let(:user_params) { valid_user }

      it 'creates a user successfully' do
        post_user
        expect(response).to have_http_status(:created)
      end

      it 'returns success message after user creation' do
        post_user
        expect(json_body['status']['message']).to eq('User created successfully.')
      end
    end

    describe 'invalid context' do
      let(:user_params) { invalid_user }

      it 'returns error when user creation fails due to invalid params' do
        post_user
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

end

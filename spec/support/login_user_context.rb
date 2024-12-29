RSpec.shared_context :login_user do |admin: false|
  let(:current_user) { create(:user, admin ? :admin : :user) }
  let(:auth_token) { Warden::JWTAuth::UserEncoder.new.call(current_user, :user, nil).first }
  let(:headers) { { 'Authorization' => "Bearer #{auth_token}" } }

end

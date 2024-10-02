RSpec.shared_context :login_user do |admin: false|
  let(:current_user) { create(:user, admin ? :admin : :user) }
  before { sign_in current_user }
end
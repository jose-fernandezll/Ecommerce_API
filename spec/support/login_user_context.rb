require 'rails_helper'
RSpec.shared_context :login_user do
  let(:current_user) { create(:user) }
  before { sign_in current_user }
end
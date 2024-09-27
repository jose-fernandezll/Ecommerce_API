require 'rails_helper'
RSpec.shared_context :login_user do
  let(:user) { create(:user) }
  before { sign_in user }
end
require 'rails_helper'
RSpec.shared_context :login_user do
  let(:usuario) { create(:user) }
  before { sign_in usuario }
end
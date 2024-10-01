require 'rails_helper'
RSpec.shared_context :logout_user do
  before { sign_out current_user }
end
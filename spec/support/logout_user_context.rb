require 'rails_helper'
RSpec.shared_context :logout_user do
  before { sign_out user }
end
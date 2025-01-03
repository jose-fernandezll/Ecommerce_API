class ApplicationController < ActionController::API
  include Devise::Controllers::Helpers

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :skip_session_storage

  include Pundit::Authorization
  include RescueErrors

  rescue_from Pundit::NotAuthorizedError, with: :render_forbidden


  private

  def render_forbidden
    render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
  end

  def skip_session_storage
    request.session_options[:skip] = true
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name role])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name role])
  end
end

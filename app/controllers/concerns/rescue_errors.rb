
module RescueErrors
  extend ActiveSupport::Concern

  included do

    rescue_from ActiveRecord::RecordNotFound do |error|
      render json: { message: "Couldn't find #{error.model}", type: error.class, model: error.model }, status: :not_found
    end

    rescue_from ActionController::ParameterMissing do |error|
      render json: { error: "Required parameter missing: #{error.param}" }, status: :bad_request
    end
  end
end
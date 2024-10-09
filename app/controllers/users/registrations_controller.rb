# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  def create
    build_resource(sign_up_params)

    if resource.save
      # Generamos el token manualmente sin iniciar sesión
      @token = Warden::JWTAuth::UserEncoder.new.call(resource, :user, nil).first
      headers['Authorization'] = @token

      render json: {
        status: { code: 201, message: 'User created successfully.' },
        token: @token,
        data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
      }, status: :created
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end

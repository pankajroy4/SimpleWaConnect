class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  skip_before_action :verify_signed_out_user
  before_action :disable_session

  def create
    # Revoke all previous token on new login.
    resource = warden.authenticate!(auth_options)
    resource.update(jti: SecureRandom.uuid)
    warden.logout(resource_name)

    sign_in(resource_name, resource, store: false)
    token = request.env["warden-jwt_auth.token"]

    render json: { token: token, token_type: "Bearer", expires_in: Devise::JWT.config.expiration_time, user: { id: resource.id, email: resource.email } }, status: :created
  end

  def destroy
    # if token is not provided then no logout. If invalid token (JIT Mismatch) is provided then devise rotate the JTI bydefault and make all previous token invalid.
    unless current_user
      return render json: { error: "Unauthorized" }, status: :unauthorized
    end

    # current_user.update!(jti: SecureRandom.uuid) # On JTI mismatch, devise will auto rotate the JTI.
    render json: { success: true }, status: :ok
  end

  # def create
  #   # all previous token is still valid
  #   self.resource = warden.authenticate!(auth_options)
  #   sign_in(resource_name, resource)
  #   token = request.env["warden-jwt_auth.token"]

  #   render json: {
  #            token: token,
  #            token_type: "Bearer",
  #            expires_in: Devise::JWT.config.expiration_time,
  #            user: { id: resource.id, email: resource.email },
  #          }, status: :created
  # end

  protected

  def disable_session
    request.session_options[:skip] = true
  end
end

module Api
  module V1
    class Api::V1::BaseController < ActionController::API
      before_action -> { request.format = :json }
      before_action :disable_session
      before_action :authenticate_user!

      # Provide JSON error format
      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { error: e.message }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: e.message }, status: :bad_request
      end

      private

      def disable_session
        request.session_options[:skip] = true
      end
    end
  end
end

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  allow_browser versions: :modern
  include Pagy::Backend

  private

  def handle_not_found
    redirect_to root_path, alert: "Record not found"
  end
end
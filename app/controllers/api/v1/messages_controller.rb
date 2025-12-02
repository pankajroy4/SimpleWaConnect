class Api::V1::MessagesController < Api::V1::BaseController
  def create
    result = Messages::Create.call(current_user: current_user, params: message_params, bulk_created: true)

    data = result.data || {}
    if result.success?
      render json: { success: true, queued_message_ids: data[:queued_message_ids] || [], errors: data[:errors] || [] }, status: result.http_status
    else
      render json: { success: false, error: result.error, details: result.details }, status: result.http_status
    end
  end

  private

  def message_params
    params.require(:messages).map do |message|
      message.permit(:message_type, :sender_phone_number, :template_name, :language_code, :media_url, :filename, :body_text, :media_type, :caption,
                     recipients: [:name, :mobile_no], header_vars: {}, body_vars: {}, button_vars: {})
    end
  end
end

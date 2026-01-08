class Api::V1::MessagesController < Api::V1::BaseController
  def create
    message_group = params[:message_group]
    result = Messages::Create.call(current_user: current_user, params: message_params, bulk_created: true, message_group:)

    data = result.data || {}
    if result.success?
      render json: { success: true, queued_messages: data[:queued_messages] || [], errors: data[:errors] || [] }, status: result.http_status
    else
      render json: { success: false, error: result.error, details: result.details }, status: result.http_status
    end
  end

  def show
    id = params[:id]
    message = current_user.messages.find(id)

    render json: get_message_response(message), status: 200
  end

  private

  def get_message_response(message)
    success_response =
      {
        "message_id" => message.id,
        "status" => message.status,
        "message_group" => message.message_group,
        "recipient" => message.customer.phone_number,
      }

    return success_response.to_json unless message.failed?
    success_response.merge({ error: { message: message.error_text, data: message.response_json } }).as_json
  end

  def message_params
    params.require(:messages).map do |message|
      message.permit(:message_type, :sender_phone_number, :template_name, :language_code, :media_url, :filename, :body_text, :media_type, :caption,
                     recipients: [:name, :mobile_no], header_vars: {}, body_vars: {}, button_vars: {})
    end
  end
end

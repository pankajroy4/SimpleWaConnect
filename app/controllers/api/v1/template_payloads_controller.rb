class Api::V1::TemplatePayloadsController < Api::V1::BaseController
  def resolve
    result = Payloads::Structure.call(
      params: payload_params.merge(account: current_user.account),
    )

    if result.success?
      render json: result.data, status: 200
    else
      render json: { error: result.error }, status: result.http_status
    end
  end

  private

  def payload_params
    {
      template_name: params[:template_name],
      language_code: params[:language_code] || "en_US",
    }
  end
end

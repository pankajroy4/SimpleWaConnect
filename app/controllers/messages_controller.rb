class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_customer

  def index
    before_id = params[:before_id]
    scope = @customer.messages
    scope = scope.where("messages.id < ?", before_id) if before_id.present?
    @messages = scope.order(id: :desc).limit(50).reverse
    render partial: "messages/messages", locals: { messages: @messages }
  end

  def create
    if params[:body_text].blank? && attachments_empty?(params[:attachment])
      flash.now[:alert] = "Message or attachment required"
      return render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
    end

    result = Messages::WebCreate.call(
      customer: @customer,
      user: current_user,
      body_text: params[:body_text],
      attachment: params[:attachment],
    )

    unless result.success?
      flash.now[:alert] = result.error.humanize
      return render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
    end

    @message = result.message

    respond_to do |format|
      format.turbo_stream { render "messages/create", locals: { new_message: @message } }
      format.html { redirect_to customer_path(@customer) }
      format.json { render json: { success: true, id: @message.id } }
    end
  end

  private

  def set_account
    @account = current_user.account
  end

  def set_customer
    @customer = @account.customers.find(params[:customer_id])
  end

  def attachments_empty?(value)
    return true if value.blank?
    Array(value).reject(&:blank?).empty?
  end
end

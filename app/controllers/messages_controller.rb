class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  before_action :set_customer

  def index
    scope = @customer.messages.includes(:user).order(created_at: :desc, id: :desc)
    @pagy, @messages = pagy_keyset(scope, items: 30)
    @messages = @messages.reverse
    render partial: "messages/infinite_batch", locals: { messages: @messages, pagy: @pagy }
  end

  def create
    if params[:body_text]&.strip().blank? && attachments_empty?(params[:attachment])
      flash.now[:alert] = "Message or attachment required"
      return render turbo_stream: turbo_stream.update("flash", partial: "layouts/flash")
    end

    result = Messages::WebCreate.call(
      customer: @customer,
      user: current_user,
      body_text: params[:body_text]&.strip(),
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

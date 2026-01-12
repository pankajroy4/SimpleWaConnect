class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def index
    scope = @account.customers.order(updated_at: :desc, id: :desc)
    @pagy, @customers = pagy_keyset(scope, items: 30)
    preload_last_messages!(@customers)
    if params[:page].present?
      render partial: "customers/infinite_batch", locals: { customers: @customers, pagy: @pagy }
    end
  end

  def show
    @customers = @account.customers.order(updated_at: :desc)
    @customer = @account.customers.find(params[:id])
    scope = @customer.messages.includes(:user).order(created_at: :desc, id: :desc)
    @pagy, @messages = pagy_keyset(scope, items: 30)
    @messages = @messages.reverse

    if turbo_frame_request?
      render :show
    else
      preload_last_messages!(@customers)
      render :index
    end
  end

  private

  def set_account
    @account = current_user.account
  end

  def preload_last_messages!(customers)
    ids = customers.pluck(:id)

    # {customer_id => message_id}
    last_ids_by_customer = Message.where(customer_id: ids).group(:customer_id).maximum(:id)

    msg_ids = last_ids_by_customer.values.compact
    messages_by_id = Message.where(id: msg_ids).index_by(&:id)

    @last_messages = last_ids_by_customer.transform_values { |mid| messages_by_id[mid] }
  end
end

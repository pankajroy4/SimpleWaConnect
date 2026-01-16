class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def index
    scope = @account.customers.order(updated_at: :desc, id: :desc)
    @pagy_customers, @customers = pagy_keyset(scope, items: 30)
    preload_last_messages!(@customers)
  end

  def infinite_scroll
    scope = @account.customers.order(updated_at: :desc, id: :desc)
    pagy_customers, customers = pagy_keyset(scope, items: 30)
    preload_last_messages!(customers)

    render partial: "customers/infinite_batch", locals: {
      customers: customers,
      pagy_customers: pagy_customers,
    }
  end

  def show
    scope = @account.customers.order(updated_at: :desc, id: :desc)
    @pagy_customers, @customers = pagy_keyset(scope, items: 30)
    @customer = @account.customers.find(params[:id])
    scope_messages = @customer.messages.includes(:user).order(created_at: :desc, id: :desc)
    @pagy, @messages = pagy_keyset(scope_messages, items: 30)
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
    ids = customers.map(&:id)
    # {customer_id => message_id}
    last_ids_by_customer = Message.where(customer_id: ids).group(:customer_id).maximum(:id)
    msg_ids = last_ids_by_customer.values.compact
    messages_by_id = Message.where(id: msg_ids).index_by(&:id)
    @last_messages = last_ids_by_customer.transform_values { |mid| messages_by_id[mid] }
  end
end

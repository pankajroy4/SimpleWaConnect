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
    @customer.update_column(:unread_count, 0)

    if turbo_frame_request?
      render :show
    else
      preload_last_messages!(@customers)
      render :index
    end
  end

  def mark_read
    customer = @account.customers.find(params[:id])
    customer.update_column(:unread_count, 0)

    # optional: broadcast sidebar badge update to all sessions
    last_message = customer.messages.order(id: :desc).first
    Turbo::StreamsChannel.broadcast_replace_to(
      "customers_list",
      target: "last_message_and_badge_#{customer.id}",
      partial: "customers/last_message_and_badge",
      locals: { customer: customer, last_message: last_message },
    )

    head :ok
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

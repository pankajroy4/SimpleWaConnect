class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def index
    @customers = @account&.customers&.order(updated_at: :desc) || []
  end

  def show
    @customers = @account.customers.order(updated_at: :desc)
    @customer = @account.customers.find(params[:id])
    scope = @customer.messages.includes(:user).order(created_at: :desc, id: :desc)
    @pagy, @messages = pagy_keyset(scope, items: 30)
    @messages = @messages.reverse
  end

  private

  def set_account
    @account = current_user.account
  end
end

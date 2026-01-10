class CustomersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account

  def index
    @customers = @account&.customers&.order(updated_at: :desc) || []
  end

  def show
    @customers = @account.customers&.order(updated_at: :desc) || []
    @customer = @account.customers&.find(params[:id])
    @messages = @customer&.messages&.includes(:user)&.order(created_at: :desc)&.limit(30)&.reverse || []
  end

  private

  def set_account
    @account = current_user.account
  end
end

# ============== app/models/customer.rb ==============
class Customer < ApplicationRecord
  belongs_to :account
  has_many :messages

  validates :phone_number, presence: true
  # after_create_commit :broadcast_creation, unless: :bulk_created?

  def display_name
    name.presence || phone_number
  end

  def last_message_at
    messages.order(created_at: :desc).limit(1).pluck(:created_at).first
  end

  private

  # def broadcast_creation
  #   broadcast_prepend_to "customers_list", target: "chats-list", partial: "customers/list_item", locals: { customer: self }
  # end
end

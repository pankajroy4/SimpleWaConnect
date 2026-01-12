class Customer < ApplicationRecord
  belongs_to :account
  has_many :messages

  validates :phone_number, presence: true
  after_create_commit :broadcast_creation, unless: :bulk_created?

  def display_name
    name.presence || phone_number
  end

  def last_message_at
    messages.order(created_at: :desc).limit(1).pluck(:created_at).first
  end

  def unread_count
    # incoming messages not yet read
    Message.joins(:customer_messages).where(customer_messages: { customer_id: id }).where(direction: "incoming").where.not(status: "read").count
  end

  def incoming?
    direction == "incoming"
  end

  private

  def broadcast_creation
    broadcast_prepend_to "customers_list", target: "chats-list", partial: "customers/list_item", locals: { customer: self, initial_unread: 1 }
  end
end

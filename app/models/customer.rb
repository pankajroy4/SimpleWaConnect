class Customer < ApplicationRecord
  belongs_to :account

  has_many :customer_messages, dependent: :destroy
  has_many :messages, through: :customer_messages

  validates :phone_number, presence: true

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
end

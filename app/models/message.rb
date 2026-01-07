class Message < ApplicationRecord
  belongs_to :account
  belongs_to :template, optional: true
  belongs_to :customer

  belongs_to :user, optional: true

  enum :status, { queued: "queued", processing: "processing", accepted: "accepted", delivered: "delivered", read: "read", failed: "failed" }

  enum :direction, { incoming: "incoming", outgoing: "outgoing" }

  enum :message_type, { template_message: "template_message", non_template_message: "non_template_message" }

  validates :direction, presence: true
  validates :template, presence: true, if: :template_message?

  after_create_commit :broadcast_creation, unless: :bulk_created?
  after_update_commit :broadcast_update, unless: :bulk_created?

  def incoming?
    direction == "incoming"
  end

  private

  def broadcast_creation
    # customers.each do |customer|
      # append message to chat
      broadcast_append_to "customers_list", target: "messages-list-#{customer.id}", partial: "messages/message", locals: { message: self }

      # update sidebar item
      broadcast_update_to "customers_list", target: "last_message_customer_#{customer.id}", partial: "customers/last_message", locals: { customer: customer }

      # update last_seen
      broadcast_update_to "customers_list", target: "last_active_customer_#{customer.id}", partial: "customers/last_active", locals: { customer: customer }
    # end
  end

  def broadcast_update
    # customers.each do |customer|
      broadcast_replace_to "customers_list", target: "status_message_#{self.id}", partial: "messages/status_tick", locals: { message: self }
    # end
  end
end

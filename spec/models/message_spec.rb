require "rails_helper"

RSpec.describe Message, type: :model do
  let(:customer) { create(:customer) }

  it { should belong_to(:account) }
  it { should belong_to(:customer) }
  it { should belong_to(:template).optional }

  it { should validate_presence_of(:direction) }

  it "requires template if template_message" do
    msg = build(:message, message_type: :template_message, template: nil)
    expect(msg).not_to be_valid
  end

  it "increments unread count for incoming message" do
    customer = create(:customer, unread_count: 0)

    expect {
      create(:message, :incoming, customer: customer)
    }.to change { customer.reload.unread_count }.by(1)
  end

  it "does not increment unread count for outgoing messages" do
    expect {
      create(:message, customer: customer, direction: :outgoing)
    }.not_to change { customer.reload.unread_count }
  end

  it "requires template for template message" do
    message = build(:message, message_type: :template_message, template: nil)
    expect(message).not_to be_valid
  end
end

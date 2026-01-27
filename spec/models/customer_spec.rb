require 'rails_helper'

RSpec.describe Customer, type: :model do
  it { should belong_to(:account) }
  it { should have_many(:messages) }
  it { should validate_presence_of(:phone_number) }

  describe "#display_name" do
    it "returns name if present" do
      customer = build(:customer, name: "John")
      expect(customer.display_name).to eq("John")
    end

    it "returns phone if name blank" do
      customer = build(:customer, name: nil, phone_number: "123")
      expect(customer.display_name).to eq("123")
    end
  end

  describe "#last_message_at" do
    it "returns timestamp of latest message" do
      customer = create(:customer)
      old_msg = create(:message, customer: customer, created_at: 1.day.ago)
      new_msg = create(:message, customer: customer, created_at: Time.current)
      expect(customer.last_message_at.to_i).to eq(new_msg.created_at.to_i)
    end
  end
end

require "rails_helper"

RSpec.describe WhatsappPhoneNumber, type: :model do
  it { should belong_to(:account) }
  it { should validate_presence_of(:phone_number_id_meta) }

  it "does not allow more than one active number per account" do
    account = create(:account) # already has 1 active from factory

    second = build(:whatsapp_phone_number, account: account, status: :active)

    expect(second).not_to be_valid
    expect(second.errors[:status]).to include("another active phone number already exists for this account")
  end
end

require 'rails_helper'

RSpec.describe Account, type: :model do
  it { should have_many(:users).dependent(:destroy) }
  it { should have_many(:templates).dependent(:destroy) }
  it { should have_many(:messages).dependent(:destroy) }
  it { should have_many(:customers).dependent(:destroy) }
  it { should have_many(:whatsapp_phone_numbers).dependent(:destroy) }
  it { should have_one(:whatsapp_credential).dependent(:destroy) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:platform) }

  it "is valid with whatsapp phone number" do
    expect(build(:account)).to be_valid
  end

  it "is invalid without whatsapp phone number" do
    account = build(:account)
    account.whatsapp_phone_numbers = []
    expect(account).not_to be_valid
  end
end

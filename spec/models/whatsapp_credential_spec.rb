require 'rails_helper'

RSpec.describe WhatsappCredential, type: :model do
  it { should belong_to(:account) }
  it { should validate_presence_of(:access_token) }
  it { should validate_presence_of(:app_secret) }
  it { should validate_presence_of(:webhook_verify_token) }
end

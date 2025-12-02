class WhatsappCredential < ApplicationRecord
  belongs_to :account

  encrypts :access_token, deterministic: true
  encrypts :app_secret, deterministic: true
  encrypts :webhook_verify_token, deterministic: true

  validates :access_token, :webhook_verify_token, :app_secret, :waba_id, presence: true
end

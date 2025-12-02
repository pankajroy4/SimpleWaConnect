class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :templates, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :whatsapp_phone_numbers, dependent: :destroy
  has_one :whatsapp_credential, dependent: :destroy

  # enum platform: { simpledairy: "simpledairy", purepani: "purepani" }

  validates :name, presence: true
  validates :platform, presence: true

  validate :must_have_whatsapp_phone_number
  accepts_nested_attributes_for :whatsapp_phone_numbers, allow_destroy: true

  private

  def must_have_whatsapp_phone_number
    if whatsapp_phone_numbers.blank?
      errors.add(:whatsapp_phone_numbers, "must have at least one WhatsApp phone number ID")
    end
  end
end

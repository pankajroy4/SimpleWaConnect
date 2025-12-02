class WhatsappPhoneNumber < ApplicationRecord
  belongs_to :account

  enum :status, { active: 0, inactive: 1 }

  scope :active, -> { where(status: :active) }

  validates :phone_number_id, presence: true, uniqueness: true
  validate :only_one_active_number_per_account, if: :active?

  private

  def only_one_active_number_per_account
    if account.whatsapp_phone_numbers.active.where.not(id: id).exists?
      errors.add(:status, "another active phone number already exists for this account")
    end
  end
end

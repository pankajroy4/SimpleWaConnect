class WhatsappPhoneNumber < ApplicationRecord
  belongs_to :account

  enum :status, { active: 0, inactive: 1 }

  scope :active, -> { where(status: :active) }

  validates :phone_number_id_meta, presence: true, uniqueness: true
  validates :display_number, :country_code, :account, :status, presence: true
  validate :only_one_active_number_per_account, if: :active?

  private

  def only_one_active_number_per_account
    return unless account

    if account.whatsapp_phone_numbers.active.where.not(id: id).exists?
      errors.add(:status, "another active phone number already exists for this account")
    end
  end
end

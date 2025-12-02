class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :account

  enum :role, { admin: "admin", staff: "staff" }
  before_validation :set_default_account, on: :create

  private

  def set_default_account
    self.account ||= Account.last
  end
end

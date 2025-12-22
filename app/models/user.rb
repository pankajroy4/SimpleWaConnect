class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :account, optional: true

  enum :role, { superadmin: "superadmin", admin: "admin", staff: "staff" }
  validates :role, :name, :email, :password, presence: true
  validates :account, presence: true, unless: :superadmin?
end

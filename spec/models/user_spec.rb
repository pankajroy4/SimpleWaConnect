require "rails_helper"

RSpec.describe User, type: :model do
  describe "account association rules" do
    it "is valid without account if superadmin" do
      user = build(:user, role: :superadmin, account: nil)
      expect(user).to be_valid
    end

    it "is invalid without account if admin" do
      user = build(:user, role: :admin, account: nil)
      expect(user).not_to be_valid
      expect(user.errors[:account]).to include("can't be blank")
    end

    it "is invalid without account if staff" do
      user = build(:user, role: :staff, account: nil)
      expect(user).not_to be_valid
    end

    it "is valid with account for non-superadmin roles" do
      user = build(:user, role: :admin, account: create(:account))
      expect(user).to be_valid
    end
  end
end

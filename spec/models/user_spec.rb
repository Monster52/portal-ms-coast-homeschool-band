require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it "rejects blank role" do
      user.role = nil
      expect(user).not_to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:announcements).dependent(:destroy) }
  end

  describe "defaults" do
    it "defaults role to parent" do
      expect(user.role).to eq("parent")
    end

    it "defaults admin to false" do
      expect(user.admin).to be false
    end
  end

  describe "#full_name" do
    it "returns first and last name when both are set" do
      user.first_name = "Jane"
      user.last_name  = "Smith"
      expect(user.full_name).to eq("Jane Smith")
    end

    it "falls back to email when name is blank" do
      user.first_name = ""
      user.last_name  = ""
      expect(user.full_name).to eq(user.email)
    end
  end

  describe "roles" do
    %w[teacher parent student].each do |r|
      it "accepts #{r} role" do
        user.role = r
        expect(user).to be_valid
      end
    end

    it "rejects unknown roles" do
      expect { user.role = "superuser" }.to raise_error(ArgumentError)
    end
  end

  describe "admin flag" do
    it "can be promoted to admin" do
      user.admin = true
      expect(user).to be_admin
    end
  end
end

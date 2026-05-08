require 'rails_helper'

RSpec.describe FamilyConnection, type: :model do
  let(:parent)  { create(:user, role: "parent") }
  let(:student) { create(:user, role: "student") }

  subject(:connection) { build(:family_connection, parent: parent, student: student) }

  describe "associations" do
    it { is_expected.to belong_to(:parent).class_name("User") }
    it { is_expected.to belong_to(:student).class_name("User") }
  end

  describe "validations" do
    it "is valid with a parent-role user and a student-role user" do
      expect(connection).to be_valid
    end

    it "rejects a non-parent as parent" do
      connection.parent = create(:user, :teacher)
      expect(connection).not_to be_valid
      expect(connection.errors[:parent]).to be_present
    end

    it "rejects a non-student as student" do
      connection.student = create(:user, role: "parent")
      expect(connection).not_to be_valid
      expect(connection.errors[:student]).to be_present
    end

    it "enforces uniqueness of parent + student pair" do
      create(:family_connection, parent: parent, student: student)
      duplicate = build(:family_connection, parent: parent, student: student)
      expect(duplicate).not_to be_valid
    end
  end

  describe "defaults" do
    it "starts unconfirmed" do
      expect(connection.confirmed).to be false
    end
  end

  describe "scopes" do
    let!(:confirmed_conn)   { create(:family_connection, :confirmed) }
    let!(:unconfirmed_conn) { create(:family_connection) }

    it "confirmed scope returns only confirmed connections" do
      expect(FamilyConnection.confirmed).to include(confirmed_conn)
      expect(FamilyConnection.confirmed).not_to include(unconfirmed_conn)
    end

    it "pending scope returns only unconfirmed connections" do
      expect(FamilyConnection.pending).to include(unconfirmed_conn)
      expect(FamilyConnection.pending).not_to include(confirmed_conn)
    end
  end
end

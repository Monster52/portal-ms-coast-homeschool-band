require 'rails_helper'

RSpec.describe Message, type: :model do
  subject(:message) { build(:message) }

  describe "associations" do
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:sender).class_name("User") }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
  end
end

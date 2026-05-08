require 'rails_helper'

RSpec.describe Announcement, type: :model do
  subject(:announcement) { build(:announcement) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "after_create_commit callback" do
    let!(:recipients) { create_list(:user, 3) }
    let!(:poster)     { create(:user, :admin) }

    it "enqueues an email to every user after creation" do
      total = User.count
      expect {
        create(:announcement, user: poster)
      }.to have_enqueued_mail(AnnouncementMailer, :new_announcement)
        .exactly(total).times
    end
  end
end

require 'rails_helper'

RSpec.describe AnnouncementMailer, type: :mailer do
  let(:poster)       { create(:user, :admin, first_name: "Bob", last_name: "Admin") }
  let(:recipient)    { create(:user, first_name: "Alice", last_name: "Parent") }
  let(:announcement) { create(:announcement, title: "Band Practice Tonight", body: "See you at 6pm!", user: poster) }
  let(:mail)         { described_class.new_announcement(announcement, recipient) }

  describe "#new_announcement" do
    it "renders the subject" do
      expect(mail.subject).to eq("New Announcement: Band Practice Tonight")
    end

    it "delivers to the recipient" do
      expect(mail.to).to eq([recipient.email])
    end

    it "delivers from the default address" do
      expect(mail.from).to include(ApplicationMailer.default[:from])
    end

    it "includes the announcement title in the body" do
      expect(mail.body.encoded).to include("Band Practice Tonight")
    end

    it "includes the announcement body in the mail body" do
      expect(mail.body.encoded).to include("See you at 6pm!")
    end

    it "includes the poster's name" do
      expect(mail.body.encoded).to include("Bob Admin")
    end

    it "addresses the recipient by name" do
      expect(mail.body.encoded).to include("Alice Parent")
    end
  end
end

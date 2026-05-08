class AnnouncementMailer < ApplicationMailer
  def new_announcement(announcement, recipient)
    @announcement = announcement
    @recipient = recipient

    mail(
      to: recipient.email,
      subject: "New Announcement: #{announcement.title}"
    )
  end
end

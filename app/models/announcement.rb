class Announcement < ApplicationRecord
  belongs_to :user

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true

  after_create_commit :broadcast_to_all_users

  private

  def broadcast_to_all_users
    User.find_each do |recipient|
      AnnouncementMailer.new_announcement(self, recipient).deliver_later
    end
  end
end

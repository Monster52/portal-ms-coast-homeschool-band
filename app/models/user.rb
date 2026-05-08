class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[teacher parent student].freeze

  enum :role, { teacher: "teacher", parent: "parent", student: "student" }

  has_one_attached :avatar

  has_many :announcements, dependent: :destroy

  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :sent_messages, class_name: "Message", foreign_key: :user_id, dependent: :destroy

  # Family connections (parents side)
  has_many :student_connections, class_name: "FamilyConnection",
                                  foreign_key: :parent_id, dependent: :destroy
  has_many :linked_students, through: :student_connections, source: :student

  # Family connections (student side)
  has_many :parent_connections, class_name: "FamilyConnection",
                                 foreign_key: :student_id, dependent: :destroy
  has_many :linked_parents, through: :parent_connections, source: :parent

  validates :role, presence: true

  def can_message?
    teacher? || parent? || admin?
  end

  def full_name
    "#{first_name} #{last_name}".strip.presence || email
  end
end

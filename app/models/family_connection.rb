class FamilyConnection < ApplicationRecord
  belongs_to :parent,  class_name: "User"
  belongs_to :student, class_name: "User"

  validates :parent_id, uniqueness: { scope: :student_id, message: "is already linked to this student" }
  validate :parent_must_have_parent_role
  validate :student_must_have_student_role

  scope :confirmed,   -> { where(confirmed: true) }
  scope :pending,     -> { where(confirmed: false) }

  private

  def parent_must_have_parent_role
    errors.add(:parent, "must have the parent role") unless parent&.parent?
  end

  def student_must_have_student_role
    errors.add(:student, "must have the student role") unless student&.student?
  end
end

class UserActivity < ApplicationRecord
  LEVELS = ["First-timer", "Beginner", "Intermediate", "Confirmed", "Pro"]
  belongs_to :profile
  belongs_to :activity
  validates :level, presence: true, inclusion: { in: LEVELS }
  validates :activity_id, uniqueness: {
    scope: :profile_id,
    message: "You already register for this activity"
  }
end

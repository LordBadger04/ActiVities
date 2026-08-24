class UserActivity < ApplicationRecord
  LEVELS = ["First-timer", "Beginner", "Intermediate", "Confirmed", "Pro"]
  belongs_to :user
  belongs_to :activity
  validates :level, presence: true, inclusion: { in: LEVELS }
end

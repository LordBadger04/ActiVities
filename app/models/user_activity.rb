class UserActivity < ApplicationRecord
  LEVELS = ["First-timer", "Beginner", "Intermediate", "Confirmed", "Pro"]
  belongs_to :profile
  belongs_to :activity
  validates :level, presence: true, inclusion: { in: LEVELS }
end

class EventMembership < ApplicationRecord
  STATUS = ["Pending", "Accepted", "Denied", "Ended"]
  belongs_to :user
  belongs_to :event
  validates :status, presence: true, inclusion: { in: STATUS }
  validates :is_admin, presence: true
  validates :user_id, uniqueness: {
    scope: :event_id,
    message: "You already take part in this activity"
  }
end

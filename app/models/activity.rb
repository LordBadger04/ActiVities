class Activity < ApplicationRecord
  GENRES = ["Sport", "Culture", "Relaxing"]
  has_many :events
  has_many :user_activities
  validates :name, presence: true, uniqueness: true
  validates :genre, presence: true, inclusion: { in: GENRES }
end

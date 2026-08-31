class Activity < ApplicationRecord
  GENRES = ["Sport", "Culture", "Relaxing"]
  has_many :events
  has_many :user_activities
  has_many :users,  through: :user_activities

  has_one_attached :photo

  validates :name, presence: true, uniqueness: true
  validates :genre, presence: true, inclusion: { in: GENRES }
end

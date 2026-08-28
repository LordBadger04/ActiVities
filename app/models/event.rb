class Event < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many :event_memberships, dependent: :destroy
  has_one :chat, dependent: :destroy
  validates :title, presence: true, length: { maximum: 20 }
  validates :location, presence: true
  validates :description, presence: true, length: { minimum: 15 }
  validates :max_participant, numericality: { greater_than: 0, only_integer: true }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :event_date, presence: true

  geocoded_by :location,
              params: { country: "fr,be" }

  after_validation :geocode, if: :will_save_change_to_location?
end

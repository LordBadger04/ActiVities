class Event < ApplicationRecord
  belongs_to :activity
  belongs_to :user

  has_many :event_memberships, dependent: :destroy
  has_many :users, through: :event_memberships
  has_one :chat, dependent: :destroy
  validates :title, presence: true, length: { maximum: 50 }
  validates :location, presence: true
  validates :description, presence: true, length: { minimum: 10 }
  validates :max_participant, numericality: { greater_than: 0, only_integer: true }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :event_date, presence: true

  geocoded_by :location,
              params: { country: "fr,be" }

  after_validation :geocode, if: :will_save_change_to_location?

  def starts_at
    combine(start_date)
  end

  def ends_at
    finish = combine(end_date) || (starts_at + 1.hour)
    finish <= starts_at ? finish + 1.day : finish
  end

  private

  def combine(time)
    return nil if event_date.blank? || time.blank?

    Time.zone.local(event_date.year, event_date.month, event_date.day, time.hour, time.min)
  end
end

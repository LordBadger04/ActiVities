class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :notifications, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :chats, through: :messages
  has_many :event_memberships
  has_many :events, through: :event_memberships
  has_many :user_activities
  has_many :activities, through: :user_activities
  has_one :profile, dependent: :destroy
  has_many :events_as_participant, through: :event_memberships, source: :event
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  encrypts :google_token, :google_refresh_token

  def google_calendar_connected?
    google_refresh_token.present?
  end
end

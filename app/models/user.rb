class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_many :messages
  has_many :chats, through: :messages
  has_many :events
  has_many :event_memberships
  has_many :user_activities
  has_many :activities, through: :user_activities
  has_one :profile, dependent: :destroy
  has_many :events_as_participant, through: :event_memberships, source: :event
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

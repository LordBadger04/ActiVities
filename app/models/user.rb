class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :messages
  has_many :user_activities, dependent: :destroy
  has_many :events
  has_many :activities, through: :user_activity
  has_many :event_memberships
  has_many :events_as_participant, through: :event_membership, source: :event
  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true
  validates :description, presence: true, length: { minimum: 15 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

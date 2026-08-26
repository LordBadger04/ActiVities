class Profile < ApplicationRecord
  belongs_to :user
  has_many :user_activities, dependent: :destroy
  has_many :activities, through: :user_activities

  accepts_nested_attributes_for :user_activities,
                                reject_if: ->(attributes) { attributes[:level].blank? },
                                allow_destroy: true

  validates :username, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  validates :age, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true
  validates :description, presence: true, length: { minimum: 15 }
end

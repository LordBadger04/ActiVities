class Chat < ApplicationRecord
  belongs_to :event
  has_many :notifications, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :users, through: :messages
end

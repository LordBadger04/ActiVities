class Chat < ApplicationRecord
  belongs_to :event
  has_many :messages
  has_many :users, through: :messages
end

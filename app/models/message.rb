class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat
  validates :content, presence: true, length: { minimum: 1 }

  after_create_commit :broadcast_message

  private

  def broadcast_message
    broadcast_append_to "chat_#{chat.id}_messages",
                        target: "messages",
                        partial: "chats/message",
                        locals: { message: self, current_user: user }
  end
end

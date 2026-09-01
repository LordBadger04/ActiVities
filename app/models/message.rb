class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat
  validates :content, presence: true, length: { minimum: 1 }

  after_create_commit :broadcast_message

  private

  def broadcast_message
    chat.users.distinct.each do |user|
      broadcast_append_to "chat_#{chat.id}_messages_#{user.id}",
                          target: "messages",
                          partial: "chats/message",
                          locals: { message: self, current_user: user, event: chat.event}
    end
  end
end

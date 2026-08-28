class ChatsController < ApplicationController
  def index
    @chats = Chat.all
  end

  def show
    @chat = Chat.find(params[:id])
    @current_user_event_membership = EventMembership.find_by(user: current_user)
  end
end

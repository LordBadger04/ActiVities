class SessionsController < ApplicationController
  before_action :authenticate_user!
  def google_calendar
    auth = request.env["omniauth.auth"]

    current_user.update!(
      google_token: auth.credentials.token,
      google_refresh_token: auth.credentials.refresh_token.presence || current_user.google_refresh_token,
      google_token_expires_at: Time.at(auth.credentials.expires_at)
    )
    chat_id = request.env["omniauth.params"]&.dig("chat_id")
    if (chat = Chat.find_by(id: chat_id))
      return redirect_to chat_path(chat), notice: "Agenda connecté"
    end
  end

  def google_disconnect
    current_user.update!(google_token: nil, google_refresh_token: nil, google_token_expires_at: nil)

    if (chat = Chat.find_by(id: params[:chat_id]))
      return redirect_to chat_path(chat), notice: "Agenda déconnecté"
    end

    redirect_to chats_path, notice: "Agenda déconnecté"
  end

  def google_failure
    if (chat = Chat.find_by(id: params[:chat_id]))
      return redirect_to chat_path(chat), notice: "Failure"
    end

    redirect_to chats_path, notice: "Failure"
  end
end

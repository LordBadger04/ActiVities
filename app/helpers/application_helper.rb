module ApplicationHelper
  # `User` declares no `has_one :profile` (FRONT_BLOCKERS.md §2.7), so the view layer
  # resolves it directly. Delete this once the association exists.
  def current_profile
    return nil unless user_signed_in?

    @current_profile ||= Profile.find_by(user: current_user)
  end

  # Bottom nav highlighting. The "Buddies" tab owns the whole explore section —
  # both faces of the Buddies|Activities toggle, plus event and profile detail.
  def nav_tab_active?(tab)
    case tab
    when :home    then controller_name == "pages"
    when :buddies then %w[events profiles event_memberships].include?(controller_name)
    when :chats   then %w[chats messages].include?(controller_name)
    else false
    end
  end

  # `start_date` / `end_date` are `t.time` columns (FRONT_BLOCKERS.md §1.4): they carry a
  # time of day and no date at all. The maquette asks for "Sat 10:00" and
  # "Saturday, 10:00 — 11:30"; only the time half is available, so that is what we render.
  def event_time_range(event)
    return nil if event.start_date.blank?

    start_at = event.start_date.strftime("%H:%M")
    return start_at if event.end_date.blank?

    "#{start_at} — #{event.end_date.strftime('%H:%M')}"
  end

  # Card meta line: "Tennis · Tennis Club Batignolles · 10:00".
  # The maquette also shows a distance ("2.3 km") — omitted, no geodata exists (§1.5).
  def event_meta_line(event)
    [ event.activity&.name, event.location, event_time_range(event) ].compact_blank.join(" · ")
  end

  # `pages#home` assigns no instance variables and the controller is out of scope for this
  # front-end pass (FRONT_BLOCKERS.md §4.1). The home feed is therefore loaded here so the
  # screen can render. Move it to `PagesController#home` as `@events` when you next touch it.
  def home_feed_events(limit = 3)
    Event.includes(:activity).order(created_at: :desc).limit(limit)
  end

  # `Profile has_many :user_activities` exists since commit 0c6f0b3, so reading works.
  # Writing still does not: `UserActivity belongs_to :user` points at a column the
  # table does not have (FRONT_BLOCKERS.md §1.7).
  def profile_activities(profile)
    return UserActivity.none if profile.blank?

    profile.user_activities.includes(:activity)
  end

  # Sports / Hobbies columns on the User page. `Activity::GENRES` is
  # ["Sport", "Culture", "Relaxing"]; the maquette splits them in two.
  def profile_activities_by_genre(profile)
    profile_activities(profile).group_by { |ua| ua.activity&.genre }
  end

  # `User` has no `has_one :profile` (FRONT_BLOCKERS.md §2.7).
  def profile_for(user)
    return nil if user.blank?

    Profile.find_by(user: user)
  end

  # Level badge ("Intermediate") for a person on a given activity.
  def level_for(profile, activity)
    return nil if profile.blank? || activity.blank?

    profile_activities(profile).find { |ua| ua.activity_id == activity.id }&.level
  end

  # Attendees of an event. `Event has_many :event_membership` (singular, §3.2).
  def event_attendees(event)
    event.event_membership.includes(:user)
  end

  # Chats hang off an event (`Chat belongs_to :event`), so the conversation is named
  # after it rather than after a person.
  def chat_title(chat)
    chat.event&.title.presence || "Conversation"
  end

  def chat_last_message(chat)
    chat.messages.order(created_at: :desc).first
  end

  # Drives the "Confirmed" badge on the pinned event card.
  # EventMembership::STATUS is ["Pending", "Accepted", "Denied", "Ended"].
  def membership_status_for(user, event)
    return nil if user.blank? || event.blank?

    EventMembership.find_by(user: user, event: event)&.status
  end

  # Display name for a profile, falling back through what the schema actually offers.
  def profile_display_name(profile)
    return "Buddy" if profile.blank?

    profile.username.presence ||
      [ profile.first_name, profile.last_name ].compact_blank.join(" ").presence ||
      "Buddy"
  end
end

module GoogleCalendar
  class PushEvent
    CALENDAR_ID = "primary".freeze
    TZ          = "Europe/Paris".freeze

    def initialize(user)
      @user = user
    end

    def call(event)
      if event.google_event_id.present?
        service.update_event(CALENDAR_ID, event.google_event_id, payload(event))
      else
        created = service.insert_event(CALENDAR_ID, payload(event))
        event.update!(google_event_id: created.id)
        created
      end
    rescue Google::Apis::ClientError => e
      raise unless e.status_code == 404 # supprimé côté Google → on recrée

      event.update!(google_event_id: nil)
      call(event)
    end

    def destroy(event)
      return if event.google_event_id.blank?

      service.delete_event(CALENDAR_ID, event.google_event_id)
      event.update!(google_event_id: nil)
    rescue Google::Apis::ClientError => e
      raise unless [404, 410].include?(e.status_code)

      event.update!(google_event_id: nil)
    end

    private

    def payload(event)
      Google::Apis::CalendarV3::Event.new(
        summary: event.title,
        description: event.description,
        location: event.location,
        start: time(event.starts_at),
        end: time(event.ends_at || (event.ends_at + 1.hour))
      )
    end

    def time(value)
      Google::Apis::CalendarV3::EventDateTime.new(date_time: value.iso8601, time_zone: TZ)
    end

    def service
      @service ||= Google::Apis::CalendarV3::CalendarService.new.tap do |s|
        s.authorization = Authorization.new(@user).client
      end
    end
  end
end

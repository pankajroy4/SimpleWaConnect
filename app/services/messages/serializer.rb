module Messages
  class Serializer
    def initialize(message)
      @m = message
    end

    def as_json
      {
        id: @m.id,
        body_text: @m.payload["body_text"],
        media_url: @m.payload["media_url"],
        media_type: @m.payload["media_type"],
        filename: @m.payload["filename"],
        caption: @m.payload["caption"],
        direction: @m.direction,
        status: @m.status,
        remote_id: @m.remote_id,
        created_at: @m.created_at.iso8601,
        user: (@m.user ? { id: @m.user.id, name: @m.user.name } : nil)
      }
    end
  end
end

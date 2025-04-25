# frozen_string_literal: true

class Volunteer
  attr_reader :client

  class << self
    def command
      "!volunteer"
    end

    def respond_to?(message)
      message.start_with?(command)
    end
  end

  def initialize(client)
    @client = client
  end

  def handle(message)
    body = message.content[:body]
    p [self.class, "handling", body]

    room = client.ensure_room message.room_id
    sender = client.get_user message.sender

    puts "[#{Time.now.strftime '%H:%M'}] <#{sender.id} in #{room.id}> \"#{message.content[:body]}\""

    volunteer = room.members.sample

    plaintext = "%<volunteer>s has volunteered!"
    html = '<a href="https://matrix.to/#/%<volunteer>s">%<volunteer>s</a> has volunteered!'

    formatdata = {
      :volunteer => volunteer.id,
      :room => room.id,
      :event => message.event_id,
    }

    from_id = MatrixSdk::MXID.new(sender.id)

    eventdata = {
      :body => format(plaintext, formatdata),
      :format => "org.matrix.custom.html",
      :formatted_body => format(html, formatdata),
      :msgtype => "m.notice",
      :"m.relates_to" => {
        :event_id => formatdata[:event],
        :from => from_id.homeserver,
      },
    }

    client.api.send_message_event(room.id, "m.room.message", eventdata)
  end
end

# frozen_string_literal: true

class Echo
  attr_reader :client

  def initialize(client)
    @client = client
  end

  def handle(message)
    msgstr = message.content[:body]
    msgstr.gsub!(/!echo\s*/, "")

    return if msgstr.empty?

    room = client.ensure_room message.room_id
    sender = client.get_user message.sender

    puts "[#{Time.now.strftime '%H:%M'}] <#{sender.id} in #{room.id}> \"#{message.content[:body]}\""

    room.send_notice(msgstr)
  end
end

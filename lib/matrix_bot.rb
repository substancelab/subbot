# frozen_string_literal: true

require "matrix_sdk"

require_relative "echo"
require_relative "ping"

class MatrixBot
  # A filter to simplify syncs
  BOT_FILTER = {
    :presence => {:types => []},
    :account_data => {:types => []},
    :room => {
      :ephemeral => {:types => []},
      :state => {
        :types => ["m.room.*"],
        :lazy_load_members => true,
      },
      :timeline => {
        :types => ["m.room.message"],
      },
      :account_data => {:types => []},
    },
  }.freeze

  def initialize(hs_url, access_token)
    @hs_url = hs_url
    @token = access_token
  end

  def run
    # Join all invited rooms
    client.on_invite_event.add_handler { |ev| client.join_room(ev[:room_id]) }

    # Run an empty sync to get to a `since` token without old data.
    # Storing the `since` token is also valid for bot use-cases, but in the
    # case of ping responses there's never any need to reply to old data.
    empty_sync = deep_copy(BOT_FILTER)
    empty_sync[:room].map { |_k, v| v[:types] = [] }
    client.sync :filter => empty_sync

    # Read all message events
    client.on_event.add_handler("m.room.message") { |ev| on_message(ev) }

    loop do
      client.sync :filter => BOT_FILTER
    rescue StandardError => error
      puts "Failed to sync - #{error.class}: #{error}"
      sleep 5
    end
  end

  def on_message(message)
    return unless message.content[:msgtype] == "m.text"

    msgstr = message.content[:body]
    return unless msgstr =~ /^!(ping|echo)\s*/

    Ping.new(client).handle(message) if msgstr.start_with? "!ping"
    Echo.new(client).handle(message) if msgstr.start_with? "!echo"
  rescue StandardError => e
    puts "[ERROR] in on_message: #{e.inspect}"
    raise
  end

  private

  def client
    @client ||= MatrixSdk::Client.new @hs_url, :access_token => @token, :client_cache => :none
  end

  def deep_copy(hash)
    Marshal.load(Marshal.dump(hash))
  end
end

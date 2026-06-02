#!/usr/bin/env ruby
# frozen_string_literal: true

require "matrix_sdk"

require_relative "lib/matrix_bot"

if $PROGRAM_NAME == __FILE__
  raise "Usage: #{$PROGRAM_NAME} [-d] homeserver_url" unless ARGV.length >= 1

  if ARGV.first == "-d"
    Thread.abort_on_exception = true
    MatrixSdk.debug!
    ARGV.shift
  end

  username = ENV["MATRIX_USERNAME"]
  password = ENV["MATRIX_PASSWORD"]

  raise "Set MATRIX_USERNAME and MATRIX_PASSWORD" unless username && password

  bot = MatrixBot.new ARGV[0], :username => username, :password => password
  bot.run
end

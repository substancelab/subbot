#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "matrix_sdk", :require => false
end

require "matrix_sdk"

require_relative "lib/matrix_bot"

if $PROGRAM_NAME == __FILE__
  raise "Usage: #{$PROGRAM_NAME} [-d] homeserver_url [access_token]" unless ARGV.length >= 1

  if ARGV.first == "-d"
    Thread.abort_on_exception = true
    MatrixSdk.debug!
    ARGV.shift
  end

  bot = MatrixBot.new ARGV[0], ENV["ACCESS_TOKEN"] || ARGV[1]
  bot.run
end

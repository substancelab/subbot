# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

A Matrix chat bot written in Ruby using the `matrix_sdk` gem. It connects to a Matrix homeserver, joins invited rooms, and responds to text commands.

## Running the bot

```bash
bundle exec ruby bot.rb [-d] <homeserver_url>
```

`ACCESS_TOKEN` must be set in the environment (e.g. via `.envrc` with direnv). The `-d` flag enables debug logging and sets `Thread.abort_on_exception = true`.

## Linting

```bash
bundle exec rubocop
```

## Architecture

`MatrixBot` (in `lib/matrix_bot.rb`) owns the sync loop and routes incoming `m.room.message` events to command handlers. On startup it does one empty sync to discard stale messages before entering the main loop.

Commands live in `lib/` as plain Ruby classes. `MatrixBot::COMMANDS` is the registry. Each command class must implement:

- `self.command` — the trigger string (e.g. `"!ping"`)
- `self.respond_to?(message_body)` — returns true if this command should handle the message
- `initialize(client)` — receives the `MatrixSdk::Client` instance
- `handle(message)` — processes the event and sends a reply

To add a new command: create a class in `lib/`, add it to `COMMANDS` in `lib/matrix_bot.rb`, and `require_relative` it there.

## Code style

RuboCop is configured with hash rockets (`{:key => value}`), double-quoted strings, trailing dots on multiline method chains, and consistent array/hash indentation. See `.rubocop.yml` for full config.

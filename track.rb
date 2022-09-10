# frozen_string_literal: true

require 'ferrum'
require 'logger'
require 'terminal-notifier'

# project-specific dependencies
require 'tracker'

logger = Logger.new('track.log')
logger.level = Logger::INFO

tracker = Tracker.new(logger: logger)
tracker.notify do |message, url|
  TerminalNotifier.notify(message,
    title: 'Refurb Tracker',
    open: url,
    ignoreDnD: true,
    group: Dir.pwd)
end

loop do
  tracker.run
  sleep 60
end

# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base

  # Automatically retry jobs twice more 5 minutes appart. First attempt count.
  retry_on Exception, wait: 5.minutes, attempts: 3
end

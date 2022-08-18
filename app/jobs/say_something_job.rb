# frozen_string_literal: true

require('logger')

class SaySomethingJob < ApplicationJob
  queue_as(:default)

  def perform
    Rails.logger.info("Hi, I'm an Example Job")
    sleep(2.seconds)
    Rails.logger.info("Something")
    sleep(2.seconds)
    Rails.logger.info("Bye!")
  end
end

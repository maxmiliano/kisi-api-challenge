class SaySomethingJob < ApplicationJob
  queue_as :default

  def perform(phrase: 'Something!')
    Rails.logger.info("Hi, I'm an Example Job")

    sleep 2.seconds
    Rails.logger.info(phrase)
    sleep 2.seconds

    Rails.logger.info('Bye!')

  end
end

# frozen_string_literal: true

require_relative("../extensions/pubsub_extensions")

class WorkerService
  using(Extensions::PubsubExtensions)

  def initialize(queue = "default", max_retry_attempts = 2)
    @queue = queue
    @max_retry = max_retry_attempts
    @logger = Rails.logger
  end

  def start
    subscriber.start
  end

  private

  def pubsub
    @pubsub ||= Pubsub.new
  end

  def subscriber
    @subscriber ||= subscription.listen do |message|
      handle(message)
    end
  end

  def subscription
    @subscription ||= pubsub.subscription(@queue)
  end

  def handle(message)
    if message.time_to_process?
      logger.info("Processing #{message.message_id} now")
      process_now(message)
    else
      logger.info("Scheduling #{message.message_id} for #{message.time_to_process}")
      message.delay!(message.remaining_time_to_schedule)
    end
  end

  def process_now(message)
    ActiveJob::Base.execute(JSON.parse(message.data))
    succeeded = true
  rescue StandarError => e
    logger.error("Error processing #{message.message_id}: #{e.message}")
    raise
  ensure
    if succeeded
      message.acknowledge!
      logger.info("Processed #{message.message_id}")
    else
      message.nack!(max_delivery_attempts: @max_retry, nack_delay: 5*120)
      logger.info("Failed to process #{message.message_id}. Delivery Attempt: #{message.delivery_attempt}")
    end
  end
end

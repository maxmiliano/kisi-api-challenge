# frozen_string_literal: true

require_relative("../extensions/pubsub_extensions")
require("logger")

class WorkerService
  using(Extensions::PubsubExtensions)

  def initialize(queue = "default", max_retry_attempts = 2)
    Rails.logger.info("Worker starting...")
    @queue = queue
    @max_retry = max_retry_attempts
    @logger = Rails.logger
  end

  def start
    subscriber.start

    ActiveSupport::Notifications.subscribe "perform.active_job" do |name, start, finish, id, payload|
      Rails.logger.info("Performing #{payload[:job]}")
    end

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
      Rails.logger.info("Processing #{message.message_id} now")
      process_now(message)
    else
      Rails.logger.info("Scheduling #{message.message_id} for #{message.time_to_process}")
      message.delay!(message.remaining_time_to_schedule)
    end
  end

  def process_now(message)
    ActiveJob::Base.execute(JSON.parse(message.data))
    succeeded = true
  rescue StandarError => e
    Rails.logger.error("Error processing #{message.message_id}: #{e.message}")
    raise
  ensure
    if succeeded
      message.acknowledge!
      Rails.logger.info("Processed #{message.message_id}")
    else
      message.nack!(max_delivery_attempts: @max_retry, nack_delay: 5*120)
      Rails.logger.info("Failed to process #{message.message_id}. Delivery Attempt: #{message.delivery_attempt}")
    end
  end
end

# frozen_string_literal: true

require_relative("../extensions/pubsub_extensions")
require("logger")

class WorkerService
  using(Extensions::PubsubExtensions)

  def initialize(queue = "default")
    Rails.logger.info("Worker starting...")
    @queue = queue
  end

  def start
    ActiveSupport::Notifications.subscribe("perform.active_job") do |_name, start, finish, _id, payload|
      Rails.logger.info("Performing #{payload[:job]}. Started at #{start}, finished at #{finish}")
    end

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
      Rails.logger.info("Processing #{message.message_id} now")
      process_now(message)
    else
      Rails.logger.info("Scheduling #{message.message_id} for #{message.time_to_process}")
      message.delay!(message.remaining_time_to_schedule)
    end
  end

  def process_now(message)
    ActiveJob::Base.execute(JSON.parse(message.data))
    Rails.logger.info("Processed #{message.message_id}.")
    message.acknowledge!
  rescue StandarError => e
    Rails.logger.error("Error processing #{message.message_id}: #{e.message}")
    message.nack!(nack_delay: 5 * 60)
    raise(e)
  end
end

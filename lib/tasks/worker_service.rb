# frozen_string_literal: true

require_relative("../extensions/pubsub_extensions")

class WorkerService
  using(Extensions::PubsubExtensions)

  def initialize(queue = "default")
    @queue = queue
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
    puts("Data: #{message.message.data}, published at #{message.message.published_at}")

    if message.time_to_process?
      puts("Message #{message.message_id} scheduled at #{message.scheduled_at} will be processed now.")
      process_now(message)
    else
      puts("Message #{message.message_id}  delaeyd in #{message.remaining_time_to_schedule} seconds")
      message.delay!(message.remaining_time_to_schedule)
    end
  end

  def process_now(message)
    succeeded = false
    failed = false
    ActiveJob::Base.execute(JSON.parse(message.data))
    succeeded = true
  rescue StandarError => e
    failed = true
    puts("Exception rescued: #{e.inspect}")
    raise
  ensure
    if succeeded || failed
      message.acknowledge!
      puts("Message #{message.message_id} was acknowledge.")
    end
  end
end

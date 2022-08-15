# frozen_string_literal: true

require_relative("../extensions/pubsub_extensions")

class WorkerService
  using(Extensions::PubsubExtensions)

  def initialize(queue = "default", max_retry_attemps = 2)
    @queue = queue
    @max_retry = max_retry_attemps
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
      puts("Message #{message.message_id} will be processed now.")
      process_now(message)
    else
      puts("Message #{message.message_id}  delayed in #{message.remaining_time_to_schedule} seconds")
      message.delay!(message.remaining_time_to_schedule)
    end
  end

  def process_now(message)
    ActiveJob::Base.execute(JSON.parse(message.data))
    succeeded = true
  rescue StandarError => e
    puts("Exception rescued: #{e.inspect}")
    raise
  ensure
    if succeeded
      message.acknowledge!
      puts("Message #{message.message_id} was acknowledge.")
    end
  end
end

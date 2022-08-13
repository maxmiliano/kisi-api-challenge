class WorkerService
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
    job = parse_message_as_job(message)
    # job.perform(*job.arguments)
    message.acknowledge!
  end

  def parse_message_as_job(message)
    serialized_job = JSON.parse(message.message.data)
    arguments = ActiveJob::Arguments.deserialize(serialized_job["arguments"])
    serialized_job["job_class"].constantize.new(*arguments)
  end
end

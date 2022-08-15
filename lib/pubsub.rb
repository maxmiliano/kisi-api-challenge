# frozen_string_literal: true

require("google/cloud/pubsub")

class Pubsub

  DEFAULT_MAX_ATTEMPTS = 2

  # Find or create a topic.
  #
  # @param topic [String] The name of the topic to find or create
  # @return [Google::Cloud::PubSub::Topic]
  def topic(name)
    topic_name = "queue-#{name}"
    client.topic(topic_name) || client.create_topic(topic_name)
  end

  def subscription(name)
    sub_name = "worker-#{name}"
    client.subscription(sub_name) || create_subscription(name, sub_name)
  end

  private

  # Create a new client.
  #
  # @return [Google::Cloud::PubSub]
  def client
    @client ||= Google::Cloud::PubSub.new(project_id: "code-challenge")
  end

  def create_subscription(name, subscription_name)
    morgue_name = "morgue-#{name}"
    morgue_topic = topic(morgue_name)
    topic(name).subscribe(subscription_name,
                          dead_letter_topic: morgue_topic,
                          dead_letter_max_delivery_attempts: DEFAULT_MAX_ATTEMPTS)
  end
end

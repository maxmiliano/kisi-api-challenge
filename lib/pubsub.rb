# frozen_string_literal: true

require("google/cloud/pubsub")

class Pubsub

  # Find or create a topic.
  #
  # @param topic [String] The name of the topic to find or create
  # @return [Google::Cloud::PubSub::Topic]
  def topic(name)
    topic_name = "queue-#{name}"
    client.topic(topic_name) || client.create_topic(topic_name)
  end

  def morgue(name)
    morgue_name = "morgue-#{name}"
    morgue_topic = topic(morgue_name)
  end

  def subscription(name)
    sub_name = "worker-#{name}"
    client.subscription(sub_name) || create_subscription(name)
  end

  private

  # Create a new client.
  #
  # @return [Google::Cloud::PubSub]
  def client
    @client ||= Google::Cloud::PubSub.new(project_id: "code-challenge")
  end

  def create_subscription(name)
    sub_name = "worker-#{name}"
    topic(name).subscribe(sub_name, dead_letter_topic: morgue(name))
  end
end

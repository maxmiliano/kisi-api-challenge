# frozen_string_literal: true

require("google/cloud/pubsub")
# require_relative("./extensions/pubsub_extension")

class Pubsub
  # using Extensions::PubsubExtension

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
    client.subscription(sub_name) || topic(name).subscribe(sub_name)
  end

  private

  # Create a new client.
  #
  # @return [Google::Cloud::PubSub]
  def client
    @client ||= Google::Cloud::PubSub.new(project_id: "code-challenge")
  end
end

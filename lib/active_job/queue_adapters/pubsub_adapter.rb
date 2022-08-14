# frozen_string_literal: true

require_relative("../../extensions/pubsub_extensions")
require("google/cloud/pubsub")
require("json")
require("logger")

module ActiveJob
  module QueueAdapters
    class PubsubAdapter
      using(Extensions::PubsubExtensions)

      # Enqueue a job to be performed.
      #
      # @param [ActiveJob::Base] job The job to be performed.
      def enqueue(job, attributes = {})
        Rails.logger.info("[PubsubAdapter enqueue job #{job.inspect}")
        topic = pubsub.topic(job.queue_name)
        message = topic.publish(JSON.dump(job.serialize), attributes)
        job.provider_job_id = message.message_id
      end

      # Enqueue a job to be performed at a certain time.
      #
      # @param [ActiveJob::Base] job The job to be performed.
      # @param [Float] timestamp The time to perform the job.
      def enqueue_at(job, timestamp)
        enqueue(job, timestamp: timestamp)
      end

      private

      # Create a new pubsub.
      #
      # @return [Pubsub]
      def pubsub
        @pubsub ||= Pubsub.new
      end
    end
  end
end

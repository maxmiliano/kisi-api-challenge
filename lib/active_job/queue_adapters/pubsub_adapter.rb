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
        attributes = attributes.merge(job.serialize)
        Rails.logger.info("Enqueuing #{job.class.name} with #{attributes}")
        message = pubsub.topic(job.queue_name).publish(JSON.dump(job.serialize), attributes)
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

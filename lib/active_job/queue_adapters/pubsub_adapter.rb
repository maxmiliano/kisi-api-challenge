# frozen_string_literal: true

module ActiveJob
  module QueueAdapters
    class PubsubAdapter
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
        raise(NotImplementedError)
      end
    end
  end
end

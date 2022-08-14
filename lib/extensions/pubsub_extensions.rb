require 'google/cloud/pubsub'

module Extensions
  module PubsubExtensions
    refine Google::Cloud::Pubsub::ReceivedMessage do
      def scheduled_at
        return nil unless (timestamp = attributes['timestamp'])
        Time.at(timestamp.to_f)
      end

      def remaining_time_to_schedule
        scheduled_at ? [(scheduled_at - Time.now).to_f.ceil, 0].max : 0
      end

      def time_to_process?
        remaining_time_to_schedule.zero?
      end
    end
  end
end


# frozen_string_literal: true

require_relative("./worker_service")

namespace(:worker) do
  desc("Run the worker")
  task(run: :environment) do
    # See https://googleapis.dev/ruby/google-cloud-pubsub/latest/index.html

    puts("Worker starting...")

    WorkerService.new("default", 2).start

    sleep
  end
end

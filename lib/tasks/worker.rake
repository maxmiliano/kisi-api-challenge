# frozen_string_literal: true

require_relative("./worker_service")

namespace(:worker) do
  desc("Run the worker")
  task(run: :environment) do
    WorkerService.new("default").start

    sleep
  end
end

# The Kisi Backend Code Challenge

I used the challenge repository as a starting point. This `README.md` has some information on how I built the solution and instructions on how to run it.

Summary of what was done so far:
- Implemented the methods on the adapter configured adapter ([lib/active_job/queue_adapters/pubsub_adapter.rb](lib/active_job/queue_adapters/pubsub_adapter.rb)) to enqueue jobs.
- Created a ([lib/tasks/worker_service.rb](lib/tasks/worker_service.rb)) class and made it responsible for listening to the pubsub queue.
- The rake task ([lib/tasks/worker.rake](lib/tasks/worker.rake)) starts the `WorkService`.
- The ([lib/pubsub.rb](lib/pubsub.rb)), which wraps the GCP Pub/Sub client, is reponsible for creating topics and subscriptions.
- Created a ([lib/extensions/pubsub_extensions.rb](lib/extensions/pubsub_extensions.rb)) to refine `Google::Cloud::Pubsub::ReceivedMessage` to make it easier to deal with delayed messages.
- Create mock classes ([app/jobs/application_job.rb](app/jobs/application_job.rb)) and ([app/jobs/say_something_job.rb](app/jobs/say_something_job.rb)) 
- I had no reason to change anything on the [Dockerfile](Dockerfile) and a [docker-compose.yml](docker-compose.yml)..

Plan for the next iteration:
- Add automated tests
- Improve error handling

To start all services, make sure you have [Docker](https://www.docker.com/products/docker-desktop/) installed and run:
```
$ docker compose up
```

To restart the worker:
```
$ docker compose restart worker
```

To start a console:
```
$ docker compose run --rm web bin/rails console
```

To create a batch of jobs:
```
# Run this inside console: 
1000.times { SaySomethingJob.perform_later }
SaySomethingJob.set(wait: 2.minutes).perform_later
```

Note: If you run docker with a VM (e.g. Docker Desktop for Mac) we recommend you allocate at least 2GB Memory

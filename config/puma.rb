# # This configuration file will be evaluated by Puma. The top-level methods that
# # are invoked here are part of Puma's configuration DSL. For more information
# # about methods provided by the DSL, see https://puma.io/puma/Puma/DSL.html.

# # Puma can serve each request in a thread from an internal thread pool.
# # The `threads` method setting takes two numbers: a minimum and maximum.
# # Any libraries that use thread pools should be configured to match
# # the maximum value specified for Puma. Default is set to 5 threads for minimum
# # and maximum; this matches the default thread size of Active Record.
# max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
# min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
# threads min_threads_count, max_threads_count

# # Specifies that the worker count should equal the number of processors in production.
# if ENV["RAILS_ENV"] == "production"
#   require "concurrent-ruby"
#   worker_count = Integer(ENV.fetch("WEB_CONCURRENCY") { Concurrent.physical_processor_count })
#   workers worker_count if worker_count > 1
# end

# # Specifies the `worker_timeout` threshold that Puma will use to wait before
# # terminating a worker in development environments.
# worker_timeout 3600 if ENV.fetch("RAILS_ENV", "development") == "development"

# # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# port ENV.fetch("PORT") { 3000 }

# # Specifies the `environment` that Puma will run in.
# environment ENV.fetch("RAILS_ENV") { "development" }

# # Specifies the `pidfile` that Puma will use.
# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# # Allow puma to be restarted by `bin/rails restart` command.
# plugin :tmp_restart

# max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
# min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
# threads min_threads_count, max_threads_count

# # Set the worker count based on available environment variable, default to 2 workers
# worker_count = ENV.fetch("WEB_CONCURRENCY") { 2 }
# workers worker_count

# # Reduce worker timeout to handle idle workers more efficiently
# worker_timeout 30

# # Specifies the `port` that Puma will listen on to receive requests; default is 3000.
# port ENV.fetch("PORT") { 3000 }

# # Specifies the `environment` that Puma will run in.
# environment ENV.fetch("RAILS_ENV") { "development" }

# # Specifies the `pidfile` that Puma will use.
# pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# # Preload the application to take advantage of Copy On Write process behavior
# # so workers use less memory.
# preload_app!

# # Allow puma to be restarted by `bin/rails restart` command.
# plugin :tmp_restart

# on_worker_boot do
#   # Worker specific setup for Rails 4.1+ (separate database connections per worker)
#   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# end

# Set thread pool size for Puma
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Use workers only in production, not in development to avoid forking issues on macOS
if ENV.fetch("RAILS_ENV", "development") == "production"
  # Set the worker count based on available environment variable, default to 2 workers
  worker_count = ENV.fetch("WEB_CONCURRENCY") { 2 }
  workers worker_count

  # Preload the application to take advantage of Copy On Write process behavior
  preload_app!
end

# Reduce worker timeout to handle idle workers more efficiently
worker_timeout 30

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart

# This block will be run when a worker boots in clustered mode
on_worker_boot do
  # Worker specific setup for Rails 4.1+ (separate database connections per worker)
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

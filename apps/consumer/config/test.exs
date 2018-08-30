use Mix.Config

config :consumer, :rabbitmq_config,
  queue: "test.queue",
  exchange: "",
  consumers: 0

config :consumer, :pool_config,
  pool_name: :test_pool,
  name: {:local, :test_pool},
  worker_module: Consumer.ConnectionWorker,
  size: 0,
  max_overflow: 0

use Mix.Config

config :consumer, :rabbitmq_config,
  queue: "emails.queue",
  exchange: "",
  pool_name: :connection_pool,
  consumers: 10

config :consumer, :pool_config,
  pool_name: :connection_pool,
  name: {:local, :connection_pool},
  worker_module: Consumer.ConnectionWorker,
  size: 5,
  max_overflow: 0

use Mix.Config

config :consumer, :rabbitmq_config,
  queue: "test.queue",
  exchange: "",
  pool_name: :connection_pool,
  consumers: 1

use Mix.Config

config :consumer, :rabbitmq_config,
  queue: "emails.queue",
  exchange: "",
  pool_name: :connection_pool,
  consumers: 10

defmodule Consumer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc """
  ## Example
  In the config file:
    config :consumer, :rabbitmq_config,
      queue: QUEUE,
      exchange: EXCHANGE,
      consumers: 100,
      reconnect_interval: 1_000

    config :consumer, :pool_config,
      pool_name: POOL_NAME,
      name: {:local, POOL_NAME},
      worker_module: ConnectionWorker,
      size: 5,
      max_overflow: 0
  """

  use Application

  alias Consumer.{ConnectionWorder, PoolSupervisor, ConsumerSupervisor}

  @rabbit_config Application.get_env(:consumer, :rabbitmq_config, [])
  @pool_config Application.get_env(:consumer, :pool_config, [])
  @pool_name Keyword.fetch!(@pool_config, :pool_name)

  def start(_type, _args) do
    children = [
      {PoolSupervisor, {@rabbit_config, @pool_config}},
      {ConsumerSupervisor, {@rabbit_config, @pool_name}}
    ]

    # if for some reason the Supervisor of the RabbitMQ connection pool is terminated we should
    # restart the Consumer supervisor because we can't consume messages from RabbitMQ without any
    # connection
    opts = [strategy: :rest_for_one, name: Consumer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

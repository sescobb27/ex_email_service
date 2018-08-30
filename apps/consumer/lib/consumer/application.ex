defmodule Consumer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Consumer.{ConnectionWorder, PoolSupervisor, ConsumerSupervisor}

  def start(_type, _args) do
    rabbit_config = Application.get_env(:consumer, :rabbitmq_config, [])

    children = [
      {PoolSupervisor, rabbit_config},
      {ConsumerSupervisor, rabbit_config}
    ]

    # if for some reason the Supervisor of the RabbitMQ connection pool is terminated we should
    # restart the Consumer supervisor because we can't consume messages from RabbitMQ without any
    # connection
    opts = [strategy: :rest_for_one, name: Consumer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

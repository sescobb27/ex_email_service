defmodule Consumer.ConsumerSupervisor do
  use Supervisor

  alias Consumer.Consumer

  def start_link(rabbit_config) do
    Supervisor.start_link(__MODULE__, rabbit_config, name: __MODULE__)
  end

  def init(rabbit_config) do
    pool_name = Keyword.fetch!(rabbit_config, :pool_name)
    consumers = Keyword.fetch!(rabbit_config, :consumers)

    children =
      for n <- 1..consumers do
        Supervisor.child_spec({Consumer, pool_name}, id: "consumer_#{n}")
      end

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end

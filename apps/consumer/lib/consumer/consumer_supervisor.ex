defmodule Consumer.ConsumerSupervisor do
  use Supervisor

  alias Consumer.Consumer

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init({rabbit_config, pool_name}) do
    consumers = Keyword.fetch!(rabbit_config, :consumers)

    children =
      if consumers != 0 do
        for n <- 1..consumers do
          Supervisor.child_spec({Consumer, pool_name}, id: "consumer_#{n}")
        end
      else
        []
      end

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end

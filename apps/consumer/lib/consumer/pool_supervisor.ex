defmodule Consumer.PoolSupervisor do
  use Supervisor

  alias Consumer.ConnectionWorker

  def start_link(rabbit_config) do
    Supervisor.start_link(__MODULE__, rabbit_config)
  end

  @impl true
  def init(rabbit_config) do
    pool_name = Keyword.fetch!(rabbit_config, :pool_name)

    # TODO: make this configurable
    pool_config = [
      name: {:local, pool_name},
      worker_module: ConnectionWorker,
      size: 5,
      max_overflow: 0
    ]

    children = [
      :poolboy.child_spec(pool_name, pool_config, rabbit_config)
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end

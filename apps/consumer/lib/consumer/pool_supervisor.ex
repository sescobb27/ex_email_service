defmodule Consumer.PoolSupervisor do
  use Supervisor

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args)
  end

  @impl true
  def init({rabbit_config, pool_config}) do
    pool_name = Keyword.fetch!(pool_config, :pool_name)

    children = [
      :poolboy.child_spec(pool_name, pool_config, rabbit_config)
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end

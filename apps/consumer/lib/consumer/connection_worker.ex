defmodule Consumer.ConnectionWorker do
  use GenServer
  use AMQP

  require Logger

  @reconnect_interval 1_000

  defmodule State do
    defstruct connection: nil, config: nil
  end

  ##############
  # Client API #
  ##############

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, [])
  end

  def get_connection(pid) do
    GenServer.call(pid, :conn)
  end

  @doc false
  def state(pid) do
    GenServer.call(pid, :state)
  end

  ####################
  # Server Callbacks #
  ####################
  @impl true
  def init(config) do
    Process.flag(:trap_exit, true)
    send(self(), :connect)
    {:ok, %State{config: config}}
  end

  @impl true
  def handle_call(:conn, _from, %{connection: nil} = state) do
    {:reply, {:error, :disconnected}, state}
  end

  @impl true
  def handle_call(:conn, _from, %{connection: connection} = state) do
    {:reply, {:ok, connection}, state}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:connect, %{config: config, config: config} = state) do
    Connection.open(config)
    |> handle_rabbit_connect(state)
  end

  # connection crashed
  @impl true
  def handle_info({:EXIT, pid, reason}, %{connection: %{pid: pid}, config: config} = state) do
    Logger.error("[error] connection lost, attempting to reconnect reason: #{inspect(reason)}")
    # TODO: use exponential backoff to reconnect
    # TODO: use circuit breaker to fail fast
    schedule_connect(config)
    {:noreply, %State{state | connection: nil}}
  end

  @impl true
  def terminate(_reason, %{connection: connection, config: config}) do
    try do
      Connection.close(connection)
    catch
      _, _ -> :ok
    end
  end

  def terminate(_reason, _state) do
    :ok
  end

  #############
  # Internals #
  #############

  defp handle_rabbit_connect({:error, reason}, %{config: config} = state) do
    Logger.error("[error] error reason: #{inspect(reason)}")
    # TODO: use exponential backoff to reconnect
    # TODO: use circuit breaker to fail fast
    schedule_connect(config)
    {:noreply, state}
  end

  defp handle_rabbit_connect({:ok, connection}, state) do
    %{pid: pid} = connection
    true = Process.link(pid)
    {:noreply, %State{state | connection: connection}}
  end

  defp schedule_connect(config) do
    interval = get_reconnect_interval(config)
    Process.send_after(self(), :connect, interval)
  end

  defp get_reconnect_interval(config) do
    Keyword.get(config, :reconnect_interval, @reconnect_interval)
  end
end

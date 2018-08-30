defmodule Consumer.Consumer do
  use GenServer
  use AMQP

  require Logger

  alias Consumer.ConnectionWorker

  defmodule State do
    defstruct pool_name: nil, channel: nil, monitor: nil, consumer_tag: nil
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  ####################
  # Server Callbacks #
  ####################

  def init(pool_name) do
    send(self(), :connect)
    {:ok, %State{pool_name: pool_name}}
  end

  @impl true
  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info(:connect, %{pool_name: pool_name} = state) do
    worker_pid = :poolboy.checkout(pool_name)
    :ok = :poolboy.checkin(pool_name, worker_pid)

    case ConnectionWorker.get_connection(worker_pid) do
      {:ok, conn} ->
        conn
        |> Channel.open()
        |> handle_channel(state)

      {:error, error} ->
        Logger.error("[error] couldn't get a connection")
        schedule_connect()
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(
        {:DOWN, monitor, :process, chan_pid, reason},
        %{monitor: monitor, channel: %{pid: chan_pid}} = state
      ) do
    Logger.error("[error] channel down reason: #{inspect(reason)}")
    schedule_connect()
    {:noreply, %State{state | monitor: nil, consumer_tag: nil, channel: nil}}
  end

  ################################
  # AMQP Basic.Consume Callbacks #
  ################################

  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}},
        %{channel: channel} = state
      ) do
    # TODO: do not pass it as is, instead validate it, cast it and the send it
    case ServiceMailer.send_email(payload) do
      {:error, error} ->
        Logger.error("[error] processing email reason #{inspect error}")
        Basic.reject(channel, tag, requeue: true)

      _ ->
        Basick.ack(channel, tag)
        Logger.info("[success] email processed")
    end

    {:noreply, state}
  end

  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, state) do
    Logger.error("[error] consumer was cancelled by the broker (basic_cancel)")
    {:stop, :normal, %State{state | channel: nil}}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, state) do
    Logger.error("[error] consumer was cancelled by the broker (basic_cancel_ok)")
    {:stop, :normal, %State{state | channel: nil}}
  end

  defp handle_channel({:ok, %{pid: channel_pid} = channel}, %State{} = state) do
    case handle_consume(channel) do
      {:ok, consumer_tag} ->
        ref = Process.monitor(channel_pid)
        {:noreply, %State{state | channel: channel, monitor: ref, consumer_tag: consumer_tag}}

      {:error, reason} ->
        Logger.error("[error] error consuming channel reason: #{inspect(reason)}")
        schedule_connect()
        {:noreply, %State{state | channel: nil, consumer_tag: nil}}
    end
  end

  defp handle_channel({:error, reason}, state) do
    # TODO: use exponential backoff to reconnect
    # TODO: use circuit breaker to fail fast
    Logger.error("[error] error getting channel reason: #{inspect(reason)}")
    :timer.sleep(1000)
    schedule_connect()
    {:noreply, state}
  end

  defp handle_consume(channel) do
    rabbit_config = Application.get_env(:consumer, :rabbitmq_config, [])
    queue = Keyword.fetch!(rabbit_config, :queue)
    Basic.consume(channel, queue, self(), rabbit_config)
  end

  defp schedule_connect() do
    send(self(), :connect)
  end
end

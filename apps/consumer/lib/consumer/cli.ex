defmodule Consumer.Cli do
  use AMQP

  require Logger

  @moduledoc """
   ./produce --email '{ "to": "user@example.com", "subject": "Welcome Email", "body": "<html><body><h1>Hello World!</h1></body></html>" }'
  """

  alias Consumer.ConnectionWorker

  def main(args \\ []) do
    args
    |> parse_args()
    |> publish()
  end

  defp parse_args(args) do
    strict = [email: :string]

    {parsed_args, _, _} = OptionParser.parse(args, strict: strict)

    parsed_args
  end

  defp publish(_, 0) do
    Logger.error("[error] couldn't get a connection, out of retries")
    exit({:shutdown, 1})
  end

  defp publish(args, retries \\ 5) do
    [email: email] = args
    rabbit_config = Application.get_env(:consumer, :rabbitmq_config, [])
    pool_config = Application.get_env(:consumer, :pool_config, [])
    pool_name = Keyword.fetch!(pool_config, :pool_name)
    exchange = Keyword.get(rabbit_config, :exchange, "")
    queue = Keyword.fetch!(rabbit_config, :queue)

    worker_pid = :poolboy.checkout(pool_name)
    :ok = :poolboy.checkin(pool_name, worker_pid)

    with {:ok, conn} <- ConnectionWorker.get_connection(worker_pid),
         {:ok, channel} <- Channel.open(conn) do
      Basic.publish(channel, exchange, queue, email)
      :ok = Channel.close(channel)
    else
      {:error, error} ->
        Logger.error("[error] couldn't get a connection reason #{inspect(error)}")
        publish(args, retries - 1)
    end
  end
end

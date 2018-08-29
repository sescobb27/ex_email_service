defmodule ServiceMailer do
  alias ServiceMailer.Emails.DynamicEmail
  alias ServiceMailer.Mailer

  def send_email(body) when is_binary(body) do
    body
    |> Poison.decode!()
    |> do_send_email()
  end

  def send_email(body) when is_map(body) do
    do_send_email(body)
  end

  def do_send_email(body) do
    try do
      body
      |> DynamicEmail.dynamic()
      |> Mailer.deliver_now()
    rescue
      error ->
        {:error, error}
    end
  end
end

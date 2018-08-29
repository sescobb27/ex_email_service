defmodule ServiceMailer do
  alias ServiceMailer.Emails.DynamicEmail
  alias ServiceMailer.Mailer

  def send_email(body) when is_binary(body) do
    body
    |> Poison.decode!()
    |> DynamicEmail.dynamic()
    |> Mailer.deliver_now()
  end

  def send_email(body) when is_map(body) do
    body
    |> DynamicEmail.dynamic()
    |> Mailer.deliver_now()
  end
end

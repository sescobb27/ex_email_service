defmodule ServiceMailer do
  alias ServiceMailer.Emails.DynamicEmail
  alias ServiceMailer.Mailer

  # declare existing atoms
  @attrs [:to, :from, :subject, :body, :template, :assigns, :cc, :bcc]

  def send_email(body) when is_binary(body) do
    body
    |> Poison.decode!()
    |> transform()
    |> do_send_email()
  end

  def send_email(body) when is_map(body) do
    body
    |> transform()
    |> do_send_email()
  end

  defp transform(body) do
    try do
      for {key, val} = kv <- body, into: %{} do
        # TODO: remove this and assign types to the emails so instead of dealing
        # with json maps deal with types
        # FIX: may become a DoS vulnerability target
        if is_atom(key) do
          kv
        else
          {String.to_existing_atom(key), val}
        end
      end
    rescue
      _ in ArgumentError ->
        raise "Unsupported key"
    end
  end

  defp do_send_email(body) do
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

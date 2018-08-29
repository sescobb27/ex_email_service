defmodule ApiWeb.EmailsController do
  use ApiWeb, :controller

  require Logger

  # there are multiple ways for securing this API
  # 1. using API tokens stored in a DB so anyone with the right tokens can send emails.
  # 2. using JWT tokens and sessions if this is going to be used from external
  # users not just for internal purposes
  # Architecture is really simple, there are 2 Apps the core one which is in charge
  # of sending emails, and this one that is just the WEB layer on top of it
  def create(conn, params) do
    # FIX: don't inject params directly, we would need to validate them, cast them and then
    # send the emails, but for now, this is ok
    case ServiceMailer.send_email(params) do
      {:error, error} ->
        Logger.error("error sending email, reason #{inspect(error)}")

        conn
        |> put_status(:unprocessable_entity)
        |> render(ApiWeb.ErrorView, "422.json")
        |> halt()

      _ ->
        send_resp(conn, :ok, "")
    end
  end
end

defmodule ServiceMailer.Emails.DynamicEmail do
  @moduledoc false
  import Bamboo.Email
  import ServiceMailer.Emails.Helpers

  def dynamic(body) when is_map(body) do
    new_email()
    |> from(from_email())
    |> html_body(body["body"])
    |> subject(body["subject"])
    |> to(body["to"])
  end
end

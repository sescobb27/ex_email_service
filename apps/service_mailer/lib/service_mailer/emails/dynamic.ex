defmodule ServiceMailer.Emails.DynamicEmail do
  @moduledoc false
  import Bamboo.Email
  import ServiceMailer.Emails.Helpers

  alias ServiceMailer.Templates

  def dynamic(%{"template" => template, "assigns" => assigns} = message) do
    bindings =
      for {key, val} <- assigns do
        # TODO: remove this and "type" the emails so instead of dealing with json maps deal with types
        # FIX: may become a DoS vulnerability target
        {String.to_atom(key), val}
      end

    new_email()
    |> from(from_email())
    |> html_body(Templates.render(template, assigns: bindings))
    |> subject(message["subject"])
    |> to(message["to"])
  end

  def dynamic(%{"body" => _} = message) do
    new_email()
    |> from(from_email())
    |> html_body(message["body"])
    |> subject(message["subject"])
    |> to(message["to"])
  end
end

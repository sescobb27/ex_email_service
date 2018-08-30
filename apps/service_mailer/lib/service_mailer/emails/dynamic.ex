defmodule ServiceMailer.Emails.DynamicEmail do
  @moduledoc false
  import Bamboo.Email
  import ServiceMailer.Emails.Helpers

  alias ServiceMailer.Templates

  def dynamic(%{template: template, assigns: assigns} = message) do
    bindings =
      for {key, val} <- assigns do
        # TODO: remove this and assign types to the emails so instead of dealing
        # with json maps deal with types
        # FIX: may become a DoS vulnerability target
        {String.to_atom(key), val}
      end

    message
    |> base_email()
    |> html_body(Templates.render(template, assigns: bindings))
  end

  def dynamic(%{body: _} = message) do
    message
    |> base_email()
    |> html_body(message[:body])
  end

  defp base_email(message) do
    new_email()
    |> from(message[:from] || from_email())
    |> subject(message[:subject])
    |> to(message[:to])
    |> cc(message[:cc])
    |> bcc(message[:bcc])
  end
end

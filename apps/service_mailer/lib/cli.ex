defmodule ServiceMailer.Cli do
  require Logger

  @moduledoc """
   ./service_mailer --to "user@example.com" --subject "Welcome Email" --template "welcome" --assigns "name::Simon,username::fakeuser"
   ./service_mailer --to "user@example.com" --subject "Welcome Email" --body "<html><body><h1>Hello World!</h1></body></html>"
  """
  def main(args \\ []) do
    args
    |> parse_args()
    |> validate()
    |> Enum.into(%{})
    |> send()
  end

  defp parse_args(args) do
    switches = [
      to: :string,
      from: :string,
      subject: :string,
      body: :string,
      template: :string,
      assigns: :string
    ]

    aliases = [s: :subject, b: :body, a: :assigns, t: :template]

    {parsed_args, _, _} = OptionParser.parse(args, switches: switches, aliases: aliases)

    parsed_args
    |> map_assigns()
  end

  defp map_assigns(args) do
    if Keyword.has_key?(args, :template) do
      {_, args} =
        Keyword.get_and_update(args, :assigns, fn
          nil ->
            %{}

          assigns ->
            new_assigns =
              assigns
              |> String.split(",")
              |> Enum.reduce(%{}, fn keypair, acc ->
                [key, value] = String.split(keypair, "::")
                Map.put_new(acc, key, value)
              end)

            {assigns, new_assigns}
        end)

      args
    else
      args
    end
  end

  defp validate(args) do
    unless args[:to] do
      raise ArgumentError, "missing --to"
    end

    unless args[:subject] do
      raise ArgumentError, "missing --subject or -s option"
    end

    if is_nil(args[:body]) && is_nil(args[:template]) do
      raise ArgumentError, "missing --body/-b or --template/-t option"
    end

    args
  end

  defp send(message) do
    case ServiceMailer.send_email(message) do
      {:error, error} ->
        Logger.error("error sending email, reason #{inspect(error)}")
        exit({:shutdown, 1})

      _ ->
        Logger.info("email sent")
    end
  end
end

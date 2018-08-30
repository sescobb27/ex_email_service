defmodule ServiceMailer.Emails.Helpers do
  def from_email() do
    mailer_config()
    |> Keyword.fetch!(:from_email)
  end

  def mailer_config() do
    Application.get_env(:service_mailer, ServiceMailer.Mailer, [])
  end
end

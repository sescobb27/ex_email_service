defmodule ServiceMailer.Emails.DynamicEmailTest do
  use ExUnit.Case, async: true

  alias ServiceMailer.Emails.DynamicEmail

  test "creates a dynamic email" do
    body = %{
      "to" => "user@example.com",
      "subject" => "Example Email",
      "body" => "<html><body><h1>Hello World!</h1></body></html>"
    }
    assert %{
      from: "noreply@test.com",
      html_body: "<html><body><h1>Hello World!</h1></body></html>",
      subject: "Example Email",
      to: "user@example.com"
    } = DynamicEmail.dynamic(body)
  end
end

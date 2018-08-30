defmodule ServiceMailer.Emails.DynamicEmailTest do
  use ExUnit.Case, async: true

  alias ServiceMailer.Emails.DynamicEmail

  test "creates a dynamic email" do
    body = %{
      to: "user@example.com",
      subject: "Example Email",
      body: "<html><body><h1>Hello World!</h1></body></html>"
    }

    assert %Bamboo.Email{
             from: "noreply@test.com",
             html_body: "<html><body><h1>Hello World!</h1></body></html>",
             subject: "Example Email",
             to: "user@example.com"
           } = DynamicEmail.dynamic(body)
  end

  test "creates a dynamic email based on a template" do
    body = %{
      to: "user@example.com",
      subject: "Welcome Email",
      template: "welcome",
      assigns: %{
        "name" => "Simon",
        "username" => "fakeuser"
      }
    }

    assert %Bamboo.Email{
             from: "noreply@test.com",
             html_body: "<h1>Welcome</h1>\n\nHello Simon, Welcome Aboard!\n",
             subject: "Welcome Email",
             to: "user@example.com"
           } = DynamicEmail.dynamic(body)
  end
end

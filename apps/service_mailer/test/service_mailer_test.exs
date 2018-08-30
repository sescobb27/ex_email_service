defmodule ServiceMailerTest do
  use ExUnit.Case
  use Bamboo.Test, shared: true

  test "sends dynamic email based on a json string" do
    ServiceMailer.send_email(
      "{\"to\":\"user@example.com\",\"subject\":\"Example Email\",\"body\":\"<html><body><h1>Hello World!</h1></body></html>\"}"
    )

    assert_email_delivered_with(
      from: {nil, "noreply@test.com"},
      to: [{nil, "user@example.com"}],
      subject: "Example Email",
      html_body: "<html><body><h1>Hello World!</h1></body></html>"
    )
  end

  test "sends dynamic email based on an already decoded json" do
    ServiceMailer.send_email(%{
      "to" => "user@example.com",
      "subject" => "Example Email",
      "body" => "<html><body><h1>Hello World!</h1></body></html>"
    })

    assert_email_delivered_with(
      from: {nil, "noreply@test.com"},
      to: [{nil, "user@example.com"}],
      subject: "Example Email",
      html_body: "<html><body><h1>Hello World!</h1></body></html>"
    )
  end

  test "sends dynamic email based on template" do
      ServiceMailer.send_email(%{
        "to" => "user@example.com",
        "subject" => "Welcome Email",
        "template" => "welcome",
        "assigns" => %{
          "name" => "Simon",
          "username" => "fakeuser"
        }
      })

      assert_email_delivered_with(
        from: {nil, "noreply@test.com"},
        to: [{nil, "user@example.com"}],
        subject: "Welcome Email",
        html_body: "<h1>Welcome</h1>\n\nHello Simon, Welcome Aboard!\n"
      )
  end
end

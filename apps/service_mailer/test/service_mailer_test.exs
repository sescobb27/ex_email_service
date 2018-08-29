defmodule ServiceMailerTest do
  use ExUnit.Case
  use Bamboo.Test, shared: true

  test "sends dynamic email based on a json string" do
    email =
      ServiceMailer.send_email(
        "{\"to\":\"user@example.com\",\"subject\":\"Example Email\",\"body\":\"<html><body><h1>Hello World!</h1></body></html>\"}"
      )

    assert_delivered_email(email)
  end

  test "sends dynamic email based on an already decoded json" do
    email =
      ServiceMailer.send_email(%{
        "to" => "user@example.com",
        "subject" => "Example Email",
        "body" => "<html><body><h1>Hello World!</h1></body></html>"
      })

    assert_delivered_email(email)
  end
end

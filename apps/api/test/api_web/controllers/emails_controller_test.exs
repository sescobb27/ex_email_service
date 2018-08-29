defmodule ApiWeb.EmailsControllerTest do
  use ApiWeb.ConnCase
  use Bamboo.Test, shared: true

  test "sends email from json payload" do
    payload = %{
      "to" => "user@example.com",
      "subject" => "Welcome Email",
      "template" => "welcome",
      "assigns" => %{
        "name" => "Simon",
        "username" => "fakeuser"
      }
    }

    assert conn
           |> post(emails_path(conn, :create), payload)
           |> response(200) == ""

    assert_email_delivered_with(
      from: {nil, "noreply@test.com"},
      to: [{nil, "user@example.com"}],
      subject: "Welcome Email",
      html_body: "<h1>Welcome</h1>\n\nHello Simon, Welcome Aboard!\n"
    )
  end

  test "send email using template" do
  end
end

defmodule ApiWeb.EmailsControllerTest do
  use ApiWeb.ConnCase
  use Bamboo.Test, shared: true

  import ExUnit.CaptureLog

  test "sends email from json payload", %{conn: conn} do
    payload = %{
      "to" => "user@example.com",
      "subject" => "Example Email",
      "body" => "<html><body><h1>Hello World!</h1></body></html>"
    }

    assert conn
           |> post(emails_path(conn, :create), payload)
           |> response(200) == ""

    assert_email_delivered_with(
      from: {nil, "noreply@test.com"},
      to: [{nil, "user@example.com"}],
      subject: "Example Email",
      html_body: "<html><body><h1>Hello World!</h1></body></html>"
    )
  end

  test "send email using template", %{conn: conn} do
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

  describe "errors" do
    import Mock

    test "error sendin email", %{conn: conn} do
      error_fn = fn _ -> {:error, :invalid} end

      with_mock ServiceMailer, send_email: error_fn do
        payload = %{}

        log =
          capture_log(fn ->
            response =
              conn
              |> post(emails_path(conn, :create), payload)
              |> json_response(422)

            assert response == %{
                     "errors" => %{"detail" => "Couldn't process the request"}
                   }

            assert_no_emails_delivered()
          end)

        assert log =~ "[error] error sending email, reason :invalid"
      end
    end
  end
end

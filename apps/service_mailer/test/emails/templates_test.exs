defmodule ServiceMailer.TemplatesTest do
  use ExUnit.Case, async: true

  alias ServiceMailer.Templates

  test "welcome email template" do
    assert Templates.render("welcome", assigns: [name: "Simon"]) ==
             "<h1>Welcome</h1>\n\nHello Simon, Welcome Aboard!\n"
  end

  test "reset password template" do
    text =
      Templates.render("reset_password",
        assigns: [name: "Simon", url: "https://reset_password.com"]
      )

    assert text =~ "Simon"
    assert text =~ "https://reset_password.com"
  end
end

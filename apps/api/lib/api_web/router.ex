defmodule ApiWeb.Router do
  use ApiWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(:put_format, :json)
    plug(:put_secure_browser_headers)
  end

  scope "/api", ApiWeb do
    pipe_through(:api)
    resources("/emails", EmailsController, only: [:create])
  end
end

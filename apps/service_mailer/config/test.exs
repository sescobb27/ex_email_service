use Mix.Config

config :service_mailer, ServiceMailer.Mailer, adapter: Bamboo.TestAdapter
config :bamboo, :refute_timeout, 100

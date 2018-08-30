use Mix.Config


config :service_mailer, ServiceMailer.Mailer,
  adapter: Bamboo.TestAdapter

# EmailService

Email sender using [Mailgun](https://www.mailgun.com/).

In your `config.exs` file:

```elixir

config :service_mailer, ServiceMailer.Mailer,
  adapter: Bamboo.MailgunAdapter,
  domain: System.get_env("MAILGUN_DOMAIN"),
  api_key: System.get_env("MAILGUN_API_KEY"),
  from_email: System.get_env("EMAIL")

config :consumer, :rabbitmq_config,
  host: System.get_env("QUEUE_HOST"), # "guest" as default
  host: System.get_env("QUEUE_PASSWORD"), # "guest" as default
  queue: System.get_env("QUEUE_NAME"),
  exchange: System.get_env("QUEUE_EXCHANGE") || "",
  consumers: 10

config :consumer, :pool_config,
  pool_name: :connection_pool,
  name: {:local, :connection_pool},
  worker_module: Consumer.ConnectionWorker,
  size: 5,
  max_overflow: 0
```

## Sending emails

### Templates

```sh
# start the REST server
$> iex -S mix phx.server
```

send a JSON POST request to /emails with "template" as attribute, in this case
we are sending an email with template welcome and name: Simon.

```sh
$> curl -X POST \
  http://localhost:4000/api/emails \
  -H 'content-type: application/json' \
  -d '{
    "to": "user@example.com",
    "subject": "Welcome Email",
    "template": "welcome",
    "assigns": { "name": "Simon" }
  }'
```

### HTML Body
or if just want to send the email directly you can use the body attribute

```sh
$> curl -X POST \
  http://localhost:4000/api/emails \
  -H 'content-type: application/json' \
  -d '{
    "to": "user@example.com",
    "subject": "Welcome Email",
    "body": "<html><body><h1>Hello World!</h1></body></html>",
  }'
```

## Queue

We are using a RabbitMQ queue to consume the emails.

**NOTE** You must have the queue already configured an pass those params as part of the
`:rabbitmq_config` application config.

For all the config options please refer to [AMQP](https://github.com/pma/amqp)

## Setting up a RabbitMQ with docker

```bash
# pull RabbitMQ image from docker
$> docker pull rabbitmq:3.7.7-management
# run docker in background
# name the container
# remove container if already exists
# attach default port between the container and your laptop
# attach default management port between the container and your laptop
# start rabbitmq with management console
$> docker run --detach --rm --hostname bunny --name roger_rabbit -p 5672:5672 -p 15672:15672 rabbitmq:3.7.7-management
# if you need to stop the container
$> docker stop roger_rabbit
# if you need to remove the container manually
$> docker container rm roger_rabbit
```

Now you can go to `http://localhost:15672/#` configure your queues and send an email test

### Queue Consumer architecture

We are going to have a pool of connections to rabbitmq and a number of Consumers
for the connection pool, each consumer is going to grab a channel to RabbitMQ, and
is going to mark itself as a consumer. when there is an error we are going to reject
and requeue the email for latter processing. if everything is ok we are going to
ACK rabbitmq telling the email was successfully processed.

## Sending Emails from the command line

```sh
# you have to go to the service mailer app in order to build the script, if not
# you are going to get ** (Mix) Building escripts for umbrella projects is unsupported
$> cd apps/service_mailer/
$> mix escript.build
$> ./service_mailer --to "user@example.com" --subject "Welcome Email" --template "welcome" --assigns "name::Simon,username::fakeuser"

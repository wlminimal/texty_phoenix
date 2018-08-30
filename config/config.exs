# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :texting,
  ecto_repos: [Texting.Repo]

# Configures the endpoint
config :texting, TextingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  render_errors: [view: TextingWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Texting.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id],
  level: :debug


# Change Later : Application.get_env()
config :stripity_stripe,
  api_key: System.get_env("STRIPE_SECRET_KEY")

config :ex_twilio,
  account_sid: System.get_env("TWILIO_ACCOUNT_SID"),
  auth_token: System.get_env("TWILIO_AUTH_TOKEN"),
  verify_api_key: System.get_env("TWILIO_VERIFY_API_KEY")

# Bamboo
config :texting, Texting.Mailer,
  # adapter: Bamboo.LocalAdapter,
  # open_email_in_browser_url: "http://localhost:4000/sent_emails"
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")

config :ueberauth, Ueberauth,
  providers: [
    facebook: { Ueberauth.Strategy.Facebook, [display: "popup"] },
    google: { Ueberauth.Strategy.Google, [] },
    identity: { Ueberauth.Strategy.Identity, [ callback_methods: ["POST"]] },
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")


config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")

config :phoenix, :template_engines,
  drab: Drab.Live.Engine

config :drab, TextingWeb.Endpoint,
  otp_app: :texting,
  live_conn_pass_through: %{
    assigns: %{
      current_user: true
    },
    private: %{
      phoenix_endpoint: true
    }
 }


config :scrivener_html,
  routes_helper: TextingWeb.Router.Helpers,
  # If you use a single view style everywhere, you can configure it here. See View Styles below for more info.
  view_style: :materialize

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_KEY"}, :instance_role],
  region: "us-west-1",
  s3: [
    scheme: "https://",
    host: "s3.us-west-1.amazonaws.com",
    region: "us-west-1"
  ]

config  :texting, Texting.Scheduler,
  jobs: [
   {"@daily", {Texting.Cronjob, :remove_orders_and_bitly, []}},
   {"@daily", {Texting.Cronjob, :remove_bitly, []}}
  ]


config :bitly,
  access_token: System.get_env("BITLY_ACCESS_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

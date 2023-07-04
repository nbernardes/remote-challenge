# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :remote,
  ecto_repos: [Remote.Repo]

config :remote, Remote.Repo, migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :remote, RemoteWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: RemoteWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Remote.PubSub,
  live_view: [signing_salt: "1pqfQx/p"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures snowflake IDs
config :snowflake,
  nodes: ["127.0.0.1", :nonode@nohost],
  epoch: 1_688_479_852

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"

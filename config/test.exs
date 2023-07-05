import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :remote, Remote.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "remote_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :remote, RemoteWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base:
    "Hp9c2OsDxGATXKmMHmu6pkKLBuZkmYePX+DcAqZH6HIDdQm2FptD0dXSQZmRLv0n",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Configures snowflake IDs
config :snowflake, adapter: Snowflake.Adapter.Inline

# Configures Oban
config :remote, Oban, testing: :manual

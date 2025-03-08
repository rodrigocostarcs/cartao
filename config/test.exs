import Config

config :caju, Caju.Repo, pool: Ecto.Adapters.SQL.Sandbox

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :caju, Caju.Repo,
  username: System.get_env("DB_USER", "caju"),
  password: System.get_env("DB_PASSWORD", "caju_password"),
  hostname: System.get_env("TEST_DB_HOST", "test_db"),
  database: "caju_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :caju, CajuWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "DXho/yId0vUnpGXLjUJUDO9qjGKhWjBHOk2X9CB0/a8jskXkgduup/Q4dQlqPlFR",
  server: false

# In test we don't send emails.
config :caju, Caju.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

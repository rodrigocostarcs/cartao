import Config

# Configure your database
config :cartao, Cartao.Repo,
  username: System.get_env("DB_USER", "cartao"),
  password: System.get_env("DB_PASSWORD", "cartao_password"),
  hostname: System.get_env("DB_HOST", "db"),
  database: System.get_env("DB_NAME", "cartao_dev"),
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :cartao, CartaoWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "0ldKxJPEtHv83T90R+gY0BxLix4T+b8CoSuDsFOGhkbTm1Bhk5XNOn/Xx9xym6pA",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :cartao, CartaoWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/cartao_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Enable dev routes for dashboard and mailbox
config :cartao, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

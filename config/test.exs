use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :dasher, Dasher.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :dasher, Dasher.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "dasher_test",
  hostname: "shopify.railgun",
  pool: Ecto.Adapters.SQL.Sandbox

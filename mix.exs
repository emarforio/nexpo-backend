defmodule Nexpo.Mixfile do
  use Mix.Project

  def project do
    [
      app: :nexpo,
      version: "0.0.1",
      elixir: "~> 1.10.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Nexpo, []},
      applications: [
        :bamboo,
        :ex_machina,
        :phoenix,
        :phoenix_pubsub,
        :phoenix_html,
        :sentry,
        :logger,
        :gettext,
        :phoenix_ecto,
        :postgrex,
        :arc_ecto,
        :plug_cowboy,
        :cowboy
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_), do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.15"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.3"},
      {:ex_machina, "~> 2.4"},
      {:poison, "~> 4.0"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:cors_plug, "~> 2.0"},
      {:plug_static_index_html, "~> 1.0.0"},
      {:ex_json_schema, "~> 0.7.4"},
      {:sentry, "~> 7.2.4"},
      {:comeonin, "~> 5.3"},
      {:bcrypt_elixir, "~> 2.2"},
      {:guardian, "~> 2.1.1"},
      {:bamboo, "~> 1.5"},
      {:excoveralls, "~> 0.13", only: :test},
      {:arc, "~> 0.11.0"},
      {:arc_ecto, "~> 0.11.3"},
      {:ex_aws, "~> 2.1.3"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.16"},
      {:httpoison, "~> 1.17"},
      {:sweet_xml, "~> 0.6"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

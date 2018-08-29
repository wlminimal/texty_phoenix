defmodule Texting.Mixfile do
  use Mix.Project

  def project do
    [
      app: :texting,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",

      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Texting.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.12"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      #From Local
      {:payment, in_umbrella: true},
      {:messageman, in_umbrella: true},
      {:bitly, in_umbrella: true},

      # # gitlab
      # {:payment, github: "wlminimal/payment"},
      # {:messageman, github: "wlminimal/messageman"},
      # {:bitly, github: "wlminimal/bitly"},
      # From hex.pm
      {:ueberauth, "~> 0.4"},
      {:ueberauth_google, "~> 0.5"},
      {:ueberauth_facebook, "~> 0.7"},
      {:ueberauth_identity, "~> 0.2"},
      {:bamboo, "~> 1.1.0"},
      {:drab, "~> 0.9.2"},

      {:scrivener_html, "~> 1.7"},
      {:scrivener_ecto, "~> 1.3"},
      {:scrivener_list, "~> 1.0"},
      {:csv, "~> 2.1"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.6"},
      {:sweet_xml, "~> 0.6"},
      {:uuid, "~> 1.1"},
      {:timex, "~> 3.0"},
      {:quantum, "~> 2.2"},
      {:number, "~> 0.5.7"},
      {:react_phoenix, "~>0.5.2"},

      # {:rummage_ecto, "~> 1.3.0-rc.0"},
      # {:rummage_phoenix, "~> 1.2.0"}

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
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end

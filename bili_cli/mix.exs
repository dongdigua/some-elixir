defmodule BiliCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :bili_cli,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
    ]
  end
  
  defp escript do
  	[main_module: BiliCli]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8.1"},
      {:poison, "~> 5.0"},
    ]
  end
end

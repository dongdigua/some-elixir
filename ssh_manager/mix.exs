defmodule SSHManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :ssh_manager,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  defp escript do
    [main_module: SSHManager.CLI]
  end
  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~>5.0.0"}
    ]
  end
end

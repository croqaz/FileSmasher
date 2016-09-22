defmodule FileSmasher.Mixfile do
  use Mix.Project

  def project do
    [app: :filesmasher,
     description: "A thin wrapper over tar & 7-zip compression tools",
     version: "0.1.5",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:porcelain]]
  end

  defp deps do
    [{:porcelain, "~> 2.0"}]
  end

  defp package do
    [name: :filesmasher,
     maintainers: ["Cristi Constantin"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/croqaz/FileSmasher"}]
  end
end

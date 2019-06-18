defmodule ImageClassifier.MixProject do
  use Mix.Project

  def project do
    [
      app: :image_classifier,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      package: [
        maintainers: ["Grigory Starinkin"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/velimir/image_classifier"}
      ],
      deps: deps()
    ]
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
      {:imgutils, git: "git@github.com:velimir/imgutils.git", branch: "master"},
      {:jaypeg, git: "git@github.com:velimir/jaypeg.git", branch: "master"},
      {:tensorflex,
       git: "git@github.com:velimir/tensorflex.git", branch: "matrix-ext"},
      {:elixir_make, "~> 0.5.2", runtime: false},
      {:ex_doc, "~> 0.20.2", runtime: false}
    ]
  end
end

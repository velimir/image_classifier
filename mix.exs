defmodule ImageClassifier.MixProject do
  use Mix.Project

  def project do
    [
      app: :image_classifier,
      description: "Use Tensorflow for image classification in Elixir",
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      package: [
        maintainers: ["Grigory Starinkin"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/velimir/image_classifier",
          "Post" => "https://www.erlang-solutions.com/blog/how-to-build-a-machine-learning-project-in-elixir.html"
        }
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
      {:imgutils, "~> 0.1.1"},
      {:jaypeg, "~> 0.1.0"},
      {:tensorflex,
       git: "git@github.com:velimir/tensorflex.git", branch: "matrix-ext"},
      {:elixir_make, "~> 0.5.2", runtime: false},
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false}
    ]
  end
end

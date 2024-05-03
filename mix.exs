defmodule CodeReview.MixProject do
  use Mix.Project

  def project do
    [
      app: :code_review,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
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
      {:supabase_potion, "~> 0.3"},
      {:supabase_gotrue, "~> 0.3"}
    ]
  end
end

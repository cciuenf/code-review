defmodule CodeReviewTest do
  use ExUnit.Case
  doctest CodeReview

  test "greets the world" do
    assert CodeReview.hello() == :world
  end
end

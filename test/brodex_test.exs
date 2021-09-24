defmodule BrodexTest do
  use ExUnit.Case
  doctest Brodex

  test "greets the world" do
    assert Brodex.hello() == :world
  end
end

defmodule MarkTest do
  use ExUnit.Case
  doctest Mark

  test "greets the world" do
    assert Mark.hello() == :world
  end
end

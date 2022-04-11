defmodule BiliCliTest do
  use ExUnit.Case
  doctest BiliCli

  test "greets the world" do
    assert BiliCli.hello() == :world
  end
end

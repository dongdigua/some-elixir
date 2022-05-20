defmodule SSHManagerTest do
  use ExUnit.Case
  doctest SSHManager

  test "greets the world" do
    assert SSHManager.hello() == :world
  end
end

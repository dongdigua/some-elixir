defmodule BeamdasmTest do
  use ExUnit.Case
  doctest Beamdasm

  test "greets the world" do
    assert Beamdasm.hello() == :world
  end
end

defmodule PairModeTest do
  use ExUnit.Case

  test "this is a test" do
    assert([{2, 3}] == PairMode.pair_mode([1, 2, 3, 4, 2, 3, 5, 6]))
  end
end

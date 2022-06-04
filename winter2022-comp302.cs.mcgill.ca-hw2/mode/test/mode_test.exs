defmodule ModeTest do
  use ExUnit.Case

  test "a list of integer" do
    assert([2] == Mode.mode([1,2,2,2,3,3,4,5,5]))
  end

  test "mixed type list" do
    assert([3, 'a'] == Mode.mode(['a', 'a', 'a', :b, :c, "d", 3, 3, 3, 4]))
  end
end

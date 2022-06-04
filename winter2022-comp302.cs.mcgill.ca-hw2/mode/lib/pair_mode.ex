defmodule PairMode do
  def pair_mode([]), do: :error

  def pair_mode(list) do
    list
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn x -> List.to_tuple(x) end)
    |> Mode.mode()
  end
end

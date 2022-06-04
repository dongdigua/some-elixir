defmodule Mode do
  def mode([]), do: :error

  def mode(list) do
    mode(list, %{})
  end

  def mode([], map) do
    most_common(map, Map.keys(map), 0)
  end

  def mode([h | t], map) do
    if h in Map.keys(map) do
      mode(t, %{map | h => map[h] + 1})
    else
      mode(t, Map.put(map, h, 0))
    end
  end

  def most_common(map, [], max) do
    Map.filter(map, fn {_k, v} -> v == max end) |> Map.keys()
  end

  def most_common(map, [h | t], max) do
    current = map[h]

    if current > max do
      most_common(map, t, current)
    else
      most_common(map, t, max)
    end
  end
end

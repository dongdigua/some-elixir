defmodule Grep.CLI do
  def main(args \\ []) do
    #IO.inspect(args)
    pattern = Enum.at(args, 0)
    flags = Enum.map(args, fn x -> Regex.run(~r/-[nlivx]/i, x) end) |> List.flatten |> Enum.filter(&(&1 != nil))
    files = (args -- [pattern]) -- flags
    output = Grep.grep(pattern, flags, files)
    if is_tuple(output), do: IO.inspect(output), else: IO.write(output)
  end
end

defmodule Hanoi do
  use GenServer

  def start() do
    {[height: n, time: time], [], []} = OptionParser.parse(System.argv(), strict: [height: :integer, time: :integer])
    init_stack = Enum.map(1..n, &(&1))
    GenServer.start_link(Hanoi, %{
      from: init_stack,
      temp: [],
      to: [],
      time: time,
    } |> render(), name: :hanoi)
    hanoi(n, {:from, :temp, :to})
  end

  def hanoi(1, {from, _temp, to}), do: show(from, to)
  def hanoi(n, {from, temp, to}) do
    hanoi(n-1, {from, to, temp})
    show(from, to)
    hanoi(n-1, {temp, from, to})
  end

  def show(from, to) do
    GenServer.call(:hanoi, {:move, from, to}) |> render()
  end

  def render(hanoi) do
    n = length(hanoi.from) + length(hanoi.temp) + length(hanoi.to)
    matrix = [expand_list(hanoi.from, n), expand_list(hanoi.temp, n), expand_list(hanoi.to, n)]
             |> Enum.zip
    Enum.map(matrix, fn {from, temp, to} ->
      generate_string(from, n) <> " " <> generate_string(temp, n) <> " " <> generate_string(to, n)
      |> IO.puts()
    end)
    :timer.sleep(hanoi.time)
    IO.puts IO.ANSI.clear()
    hanoi
  end

  # to each x
  # total = (2x + 1)
  # each side spaces = (n - x)
  # each side filler = (x - 1)
  def generate_string(x, n) do
    if x > 0 do
      String.duplicate("\s", n - x) <> "[" <> String.duplicate("=", x - 1) <> "|"
      <> String.duplicate("=", x - 1) <> "]" <> String.duplicate("\s", n - x)
    else
      String.duplicate("\s", n) <> "|" <> String.duplicate("\s", n)
    end
  end

  def expand_list(list, n) do
    if length(list) < n do
      expand_list([0 | list], n)
    else
      list
    end
  end

  @impl true
  def init(arg), do: {:ok, arg}
  @impl true
  def handle_call({:move, from, to}, _, state) do
    new = %{state | from => tl(state[from]), to => [hd(state[from]) | state[to]]}
    {:reply, new, new}
  end
end
Hanoi.start()

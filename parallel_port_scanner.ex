defmodule Scanner do
  def start() do
    argv = System.argv() #|> IO.inspect()
    if argv == [] do
      IO.puts("elixir parallel_port_scanner.ex the.ip.of.host min/max")
    else
      host = hd(argv) |> String.split(".") |> Enum.map(&String.to_integer(&1)) |> List.to_tuple()
      range = hd(tl(argv)) |> String.split("/")
      |> then(fn l -> String.to_integer(hd(l))..String.to_integer(hd(tl(l))) end)
      range
      |> Enum.chunk_every(512)
      |> Enum.map(fn x -> worker(host, x) end)
    end
  end

  def worker(host, range) do
    range
    |> Enum.map(&Task.async(fn -> scan(host, &1) end))
    |> Enum.map(&Task.await(&1))
    |> Enum.filter(fn x -> x != nil end)
    |> Enum.map(fn x -> IO.inspect(x) end)
  end

  def scan(host, port) do
    status =
      case :gen_tcp.connect(host, port, [:binary, packet: 0], 100) do
        {:ok, socket} ->
          state = :gen_tcp.send(socket, "hi")
          :gen_tcp.close(socket)
          state

        {:error, error} ->
          error
      end

    formatter(status, port)
  end

  def formatter(status, port) do
    if status == :ok do
      "#{port}: #{status}"
    else
      nil
    end
  end
end

Scanner.start()

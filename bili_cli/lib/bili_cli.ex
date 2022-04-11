defmodule BiliCli do
  import IO.ANSI
  @moduledoc """
  Documentation for `BiliCli`.
  """
  def main(_args \\ []) do
    HTTPoison.start
    IO.puts(cyan() <> """
      query a video: video
      query an up's account info: account
      query an up's relation: rel
      query an up's browse number: stat
      query a live room: live
      quit: quit
      """ <> reset())
    IO.gets(magenta() <> "what do you want> " <> reset())
    |> parse_input
    |> get_data
  end

  defp parse_input(input) do
    choise = String.trim(input)
    case choise do
      "video" -> "https://api.bilibili.com/x/web-interface/view?bvid=" <> IO.gets("BV number: ") |> String.trim
      "account" -> "https://api.bilibili.com/x/space/acc/info?mid=" <> IO.gets("UID: ") |> String.trim
      "rel" -> "https://api.bilibili.com/x/relation/stat?vmid=" <> IO.gets("UID: ") |> String.trim
      "stat" -> "https://api.bilibili.com/x/space/upstat?mid=" <> IO.gets("UID: ") |> String.trim
      "live" -> "http://api.live.bilibili.com/ajax/msg?roomid=" <> IO.gets("roomid: ") |> String.trim
      "quit" -> nil
      _ -> :invalid
    end
  end

  defp get_data(nil), do: IO.puts(green() <> "quit." <> reset())
  defp get_data(:invalid)  do
    IO.puts(yellow() <> "invalid input!" <> reset())
    main()
  end
  defp get_data(url) do
    syntax_colors = [number: :yellow, atom: :cyan, string: :green, boolean: :magenta, nil: :magenta]
    response = HTTPoison.get!(url)
    response.body
    |> Poison.decode!
    |> IO.inspect(syntax_colors: syntax_colors)
    main()
  end
end

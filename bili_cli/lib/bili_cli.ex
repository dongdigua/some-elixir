defmodule BiliCli do
  @syntax_colors [number: :yellow, atom: :cyan, string: :green, boolean: :magenta, nil: :magenta]
  import IO.ANSI
  @moduledoc """
  Documentation for `BiliCli`.
  """
  def main(_args \\ []) do
    IO.puts(light_blue() <> """
      BiliCLI by dongdigua(github.com/dongdigua/some-elixir)#{cyan()}
      query a video: video
      query an up's account info: account
      query an up's relation: rel
      query an up's browse number(need cookies): stat
      query your actions on a video(need cookies): action
      query a live room: live
      download a video#{red()}[!]#{cyan()}: download
      remove the saved cookies: rm
      quit: quit
      """ <> reset())
    IO.gets(magenta() <> "what do you want> " <> reset())
    |> parse_input
    |> get_data
  end

  defp parse_input(input) do
    choise = String.trim(input)
    case choise do
      "video" -> "https://api.bilibili.com/x/web-interface/view?bvid=" <> IO.gets("BV : ") |> String.trim
      "account" -> "https://api.bilibili.com/x/space/acc/info?mid=" <> IO.gets("UID: ") |> String.trim
      "rel" -> "https://api.bilibili.com/x/relation/stat?vmid=" <> IO.gets("UID: ") |> String.trim
      "stat" -> {"https://api.bilibili.com/x/space/upstat?mid=" <> IO.gets("UID: ") |> String.trim, :cookies}
      "action" -> {"https://api.bilibili.com/x/web-interface/archive/relation?bvid=" <> IO.gets("BV: ") |> String.trim, :cookies}
      "live" -> "http://api.live.bilibili.com/ajax/msg?roomid=" <> IO.gets("roomid: ") |> String.trim
      "download" -> {String.trim(IO.gets("BV: ")), String.trim(IO.gets("P(1 for default): ")), :download}
      "rm" -> :rm
      "quit" -> nil
      _ -> :invalid
    end
  end

  defp get_data(nil), do: IO.puts(green() <> "bye~" <> reset())
  defp get_data(:rm), do: File.rm("cookies.bilicli")
  defp get_data(:invalid)  do
    IO.puts(yellow() <> "invalid input!" <> reset())
    main()
  end
  defp get_data({url, :cookies}) do
    {:ok, pid} = File.open("cookies.bilicli", [:write, :read])
    file = IO.read(pid, :line)
    cookies = if ! is_tuple(file) and ! is_atom(file)  do
      IO.puts(yellow() <> "automatically read previous saves cookies" <> reset())
      file
    else
      IO.puts("this need cookies, this will write cookies.bilicli to save your cookie, type :help for help")
      gets = IO.gets("cookies" <> red() <> "(SESSDATA): " <> reset()) |> String.trim
      if gets == ":help" do
        IO.puts(yellow() <> "f12 -> storage -> cookie -> t.bilibili.com -> copy the SESSDATA" <> reset())
        gets_new = IO.gets("cookies" <> red() <> "(SESSDATA): " <> reset()) |> String.trim
        IO.write(pid, gets_new)
        gets_new
      else
        IO.write(pid, gets)
        gets
      end
    end
    response = HTTPoison.get!(url, %{}, hackney: [cookie: ["SESSDATA=#{cookies}"]])
    response.body
    |> Poison.decode!
    |> IO.inspect(syntax_colors: @syntax_colors)
    File.close(pid)
    main()
  end
  defp get_data({bv, p, :download}) do
    response = HTTPoison.get!("https://api.bilibili.com/x/web-interface/view?bvid=#{bv}")
    Download.getcid(response.body, p)
    |> Download.geturl(bv)
    |> Download.exec("https://www.bilibili.com/video/#{bv}?p=#{p}")
  end
  defp get_data(url) do
    response = HTTPoison.get!(url)
    response.body
    |> Poison.decode!
    |> IO.inspect(syntax_colors: @syntax_colors)
    main()
  end
end

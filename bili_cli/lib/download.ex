defmodule Download do
  def getcid(json, p) do
    parsed = Poison.decode!(json)
    pages = parsed["data"]["pages"]
    Enum.find(pages, fn x -> x["page"] == String.to_integer(p) end)["cid"]
  end
  def geturl(cid, bv) do
    get = HTTPoison.get!("https://api.bilibili.com/x/player/playurl?bvid=#{bv}&cid=#{cid}")
    json = Poison.decode!(get.body)
    {hd(json["data"]["durl"])["url"], cid}
  end
  def exec({url, cid}, referer) do
    IO.puts(IO.ANSI.cyan() <> "the url:" <> IO.ANSI.reset())
    IO.puts(IO.ANSI.yellow() <> url <> IO.ANSI.reset())
    System.shell("wget -O #{cid}.flv --referer #{referer} \"#{url}\"")
    IO.puts(IO.ANSI.green() <> "complete!" <> IO.ANSI.reset())
  end
end

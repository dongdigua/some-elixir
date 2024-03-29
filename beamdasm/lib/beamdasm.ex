#https://medium.com/learn-elixir/disassemble-elixir-code-1bca5fe15dd1
defmodule Beamdasm do
  @moduledoc """
  a simple tool to read .beam files
  """
  def main(argv) do
    #IO.inspect argv
    if length(argv) == 0 or String.trim(hd(argv), "-") == "help" do
      IO.puts(IO.ANSI.yellow() <> "run: beamdasm filename.beam" <> IO.ANSI.reset())
    else
      file = argv |> hd() |> String.trim()
      f = String.to_charlist(file)
      module = Regex.run(~r/(\S+)[.]beam/, file) |> tl() |> hd()
      {:ok, {_, [{:abstract_code, {_, ac}}]}} = :beam_lib.chunks(f, [:abstract_code])
      erl_code = :erl_prettypr.format(:erl_syntax.form_list(ac))
      File.write(module <> ".erl", erl_code) |> IO.inspect()
      asm_code = :beam_disasm.file(File.read!(f))
      File.write(module <> ".S", inspect(asm_code, pretty: true)) |> IO.inspect()
    end
  end
end
#Beamdasm.main()

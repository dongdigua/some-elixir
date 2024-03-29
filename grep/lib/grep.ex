defmodule Grep do
  @doc"""
  `-n` Prefix each matching line with its line number within its file.               [print]
  (When multiple files are present, this prefix goes *after* the filename prefix)
  `-l` Print only the names of files that contain at least one matching line.        [print]
  `-i` Match line using a case-insensitive comparison.                               [filter]
  `-v` Invert the program -- collect all lines that fail to match the pattern.       [filter]
  `-x` Only match entire lines, instead of lines that contain a match.               [filter]
  [{file, num, line}]
  """
  
  @spec grep(String.t(), [String.t()], [String.t()]) :: String.t()
  def grep(pattern, flags, files) do
    if Enum.all?(files, &File.exists?(&1)) do
      {pattern, files}
      |> filter(flags)
      |> print(flags)
      |> then(fn x -> if length(x) > 1, do: Enum.join(x, "\n") <> "\n", else: if List.to_string(x) == "", do: "", else: List.to_string(x) <> "\n" end)
    else
      {:error, :nonexist}
    end
  end

  def filter({pattern, files}, flags) do
    pat = if "-x" in flags, do: "^#{pattern}$", else: "#{pattern}"
    cas = if "-i" in flags, do: "i", else: ""
    re = Regex.compile!(pat, cas)
    {for filename <- files do
      file_lines = File.stream!(filename, [:utf8])
      lines = if "-v" in flags do
	Enum.reject(file_lines, fn x -> x =~ re end) |> Enum.map(&String.trim(&1))
      else
	Enum.filter(file_lines, fn x -> x =~ re end) |> Enum.map(&String.trim(&1))
      end
      numbers = Enum.map(lines, fn x -> Enum.find_index(file_lines, &(String.trim(&1) == String.trim(x))) + 1 end)
      Enum.zip([Enum.reduce(1..length(numbers), [], fn _x, acc -> [filename | acc] end), numbers, lines])
    end
    |> List.flatten, Enum.count(files)}
  end

  defp print({to_print, num_of_files}, flags) do
    cond do
      "-l" in flags -> Enum.map(to_print, fn {file, _num, _line} -> IO.ANSI.cyan() <> file <> IO.ANSI.reset() end) |> Enum.uniq
      "-n" in flags -> if num_of_files > 1, do: Enum.map(to_print, fn {file, num, line} -> IO.ANSI.cyan() <> "#{file}:" <> IO.ANSI.reset() <> IO.ANSI.green() <> "#{num}:" <> IO.ANSI.reset() <> "#{line}" end),
	else: Enum.map(to_print, fn {_file, num, line} -> IO.ANSI.green() <> "#{num}:" <> IO.ANSI.reset() <> "#{line}" end)
      true -> if num_of_files > 1, do: Enum.map(to_print, fn {file, _num, line} -> IO.ANSI.cyan() <> "#{file}:" <> IO.ANSI.reset() <> "#{line}" end),
	else: Enum.map(to_print, fn {_file, _num, line} -> "#{line}" end)
    end
  end  
end

defmodule BrainFuck do
  def brainfuck(code, input \\ []), do: parse(List.to_tuple(String.to_charlist(code)), 0, memory(), 0, [], input)
  def parse(code, code_ptr, mem, ptr, res, input) do
    cond do
      code_ptr >= tuple_size(code) -> res
      elem(code, code_ptr) == ?> -> parse(code, code_ptr + 1, mem, ptr + 1, res, input)
      elem(code, code_ptr) == ?< -> parse(code, code_ptr + 1, mem, ptr - 1, res, input)
      elem(code, code_ptr) == ?+ -> parse(code, code_ptr + 1, List.replace_at(mem, ptr, get_in(mem, [Access.at!(ptr)]) + 1), ptr, res, input)
      elem(code, code_ptr) == ?- -> parse(code, code_ptr + 1, List.replace_at(mem, ptr, get_in(mem, [Access.at!(ptr)]) - 1), ptr, res, input)
      elem(code, code_ptr) == ?. -> parse(code, code_ptr + 1, mem, ptr, res ++ [get_in(mem, [Access.at(ptr)])], input)
      elem(code, code_ptr) == ?, -> parse(code, code_ptr + 1, List.replace_at(mem, ptr, hd(input)), ptr, res, tl(input))
      elem(code, code_ptr) == 91 ->
	if get_in(mem, [Access.at(ptr)]) == 0 do
	  parse(code, find(code, code_ptr + 1, 0, :end), mem, ptr, res, input)
	else
	  parse(code, code_ptr + 1, mem, ptr, res, input)
	end
      elem(code, code_ptr) == 93 ->
	if get_in(mem, [Access.at(ptr)]) == 0 do
	  parse(code, code_ptr + 1, mem, ptr, res, input)
	else
	  parse(code, find(code, code_ptr - 1, 0, :begin), mem, ptr, res, input)
	end
      true -> {:error, code}
	
    end
  end
  defp memory, do: Enum.reduce(0..255, [], fn _x, acc -> acc ++ [0] end)
  defp find(code, code_ptr, count, :end) do
    cond do
      elem(code, code_ptr) == 91 -> find(code, code_ptr + 1, count + 1, :end)
      elem(code, code_ptr) == 93 and count == 0 -> code_ptr + 1
      elem(code, code_ptr) == 93 -> find(code, code_ptr + 1, count - 1, :end)
      true -> find(code, code_ptr + 1, count, :end)
    end
  end
  
  defp find(code, code_ptr, count, :begin) do
    cond do
      elem(code, code_ptr) == 93 -> find(code, code_ptr - 1, count + 1, :begin)
      elem(code, code_ptr) == 91 and count == 0 -> code_ptr + 1
      elem(code, code_ptr) == 91 -> find(code, code_ptr - 1, count - 1, :begin)
      true -> find(code, code_ptr - 1, count, :begin)
    end
  end
end
BrainFuck.brainfuck("++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.") |> IO.inspect

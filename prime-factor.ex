defmodule PrimeFactor do
  def decompose(num) do
    #num = IO.gets("> ") |> String.trim() |> String.to_integer()
    max = :math.sqrt(num) |> ceil()
    #IO.puts("sqrt: #{max}")
    pcompose(num, [], 2, max)
  end

  defp pcompose(num, res, prime, max) when prime > max do
    result = res ++ [num] -- [1]
    #IO.inspect(result)
  end
  defp pcompose(num, res, prime, max) do
    cond do
      rem(num, prime) == 0 -> pcompose(div(num, prime), res ++ [prime], prime, max)
      rem(num, prime) != 0 && rem(prime, 2) == 1 -> pcompose(num, res, prime + 2, max)
      rem(num, prime) != 0 -> pcompose(num, res, prime + 1, max)
    end
  end
end
#PrimeFactor.decompose()

	
      
	
      
  

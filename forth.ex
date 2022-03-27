# REFACTORED THREE TIMES
# I learnd a principle:
# 慢慢来，一步一步稳稳当当
# and you'll win
defmodule Forth do

  defstruct stack: [], words: %{}
  
  @arithmetic %{"+" => &(&1 + &2),
		"-" => &(&1 - &2),
		"*" => &(&1 * &2),
		"/" => &div(&1, &2)}
  @a_keys Map.keys(@arithmetic)

  def forth(s) do
    new()
    |> eval(s)
    |> format_stack()
  end
  
  @doc """
  Create a new evaluator.
  """
  def new() do
    %Forth{}
  end

  
  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  def eval(ev, s) do
    code = s
    |> String.downcase()
    |> String.split(~r/[\s\pC]/u, trim: true)
    |> Enum.map(&code_to_integer(&1))
    evalp(ev, code)
  end

  defp code_to_integer(input) do
    case Integer.parse(input) do
      {int, _} -> int
      :error -> input
    end
  end
  
  def evalp(ev, [":" | [word | t]]) when is_integer(word) do
    raise Forth.InvalidWord
  end
  
  def evalp(ev, [":" | [word | tokens]]) do
    #IO.inspect(word)
    {word_tokens, [";" | rem_tokens]} = Enum.split_while(tokens, &(&1 != ";"))
    if hd(word_tokens) in Map.keys(ev.words) do    # avoid infinite loop
      old_words = ev.words[hd(word_tokens)]
      ev_new = %{ev | words: Map.put(ev.words, word, old_words ++ tl(word_tokens))}
      evalp(ev_new, rem_tokens)
    else
      ev_new = %{ev | words: Map.put(ev.words, word, word_tokens)}
      evalp(ev_new, rem_tokens)
    end
  end

  def evalp(ev, [input_word | t]) when is_map_key(ev.words, input_word) do
    #IO.inspect(ev)
    definition = ev.words[input_word]
    #IO.inspect(definition ++ t)
    evalp(ev, definition ++ t)
  end
   
  def evalp(%Forth{stack: [0 | _]}, ["/" | _]), do: raise Forth.DivisionByZero

  def evalp(ev, [h | t]) when h in @a_keys do
    if length(ev.stack) < 2 do
      raise Forth.StackUnderflow
    else
      {a, b} = pop(ev.stack)        # [1, 2, 3, 4] -> 1
      {c, d} = pop(b)               # [2, 3, 4] -> 2
      res = @arithmetic[h].(c, a)   # 1 2 - -> -1
      %{ev | stack: push(d, res)} |> evalp(t)
    end
  end

  def evalp(ev, ["dup" | t]) do
    if length(ev.stack) < 1 do
      raise Forth.StackUnderflow
    else
      %{ev | stack: push(ev.stack, hd(ev.stack))} |> evalp(t)
    end
  end

  def evalp(ev, ["drop" | t]) do
    if length(ev.stack) < 1 do
      raise Forth.StackUnderflow
    else
      evalp(%{ev | stack: tl(ev.stack)}, t)
    end
  end

  def evalp(ev, ["swap" | t]) do
    if length(ev.stack) < 2 do
      raise Forth.StackUnderflow
    else
      {a, b} = pop(ev.stack)
      {c, d} = pop(b)
      stack_new = d |> push(a) |> push(c)
      evalp(%{ev | stack: stack_new}, t)
    end
  end

  def evalp(ev, ["over" | t]) do
    if length(ev.stack) < 2 do
      raise Forth.StackUnderflow
    else
      {a, b} = pop(ev.stack)
      {c, d} = pop(b)
      stack_new = d |> push(c) |> push(a) |> push(c)
      evalp(%{ev | stack: stack_new}, t)
    end
  end

  def evalp(ev, [h | t]) when is_integer(h)  do
    stack_new = push(ev.stack, h)
    evalp(%{ev | stack: stack_new}, t)
  end
  

  def evalp(ev, []) do
    #IO.inspect(ev)
    ev
  end

  def evalp(stack, something_strange) do
    IO.inspect(something_strange)
    raise Forth.UnknownWord
  end
   



      
  def format_stack(ev) do
    #IO.inspect(stack)
    ev.stack
    |> Enum.reverse()
    |> Enum.map(fn x -> to_string(x) end)
    |> Enum.join(" ")
  end

  def pop(stack), do: List.pop_at(stack, 0) # -> Tuple
  def push(stack, what), do: [what] ++ stack
  # IMPORTANT
  # code -> 1 2
  # [1 | _]
  # [2 | [1 | _]]












  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end

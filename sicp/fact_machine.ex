# (controller
#   (assign continue (label halt))
# fact
#   (test (op =) (reg n) (const 1))
#   (branch (label b-case))
#   (save continue)
#   (save n)
#   (assign n (op -) (reg n) (const 1))
#   (assign continue (label r-done))
#   (goto (label fact))
# r-done
#   (restore n)
#   (restore continue)
#   (assign val (op *) (reg n) (reg val))
#   (goto (reg continue))
# b-case
#   (assign val (const 1))
#   (goto (reg continue))
# halt)
#
# https://www.youtube.com/watch?v=jPDAPmx4pXE&list=PLE18841CABEA24090&index=37
defmodule Factorial do
  import GenServer, only: [call: 2]
  defmodule Register do
    defstruct [:val, :n, :continue, :stack]
  end
  # :continue -> :aft | :done
  def new(n), do: GenServer.start(__MODULE__, %Register{val: 1, n: n, continue: :done, stack: []}, [name: :register])

  def fact do
    if call(:register, {:fetch, :n}) <= 1 do
      after_fact()
    else
      fact_loop()
    end
  end

  def fact_loop do
    call(:register, {:save, :n})
    call(:register, {:save, :continue})
    call(:register, {:assign, :n, call(:register, {:fetch, :n}) - 1})
    call(:register, {:assign, :continue, :aft})
    if call(:register, {:fetch, :n}) > 0, do: fact(), else: after_fact()
  end

  def after_fact do
    call(:register, {:restore, :continue})
    call(:register, {:restore, :n})
    call(:register, {:assign, :val, (call(:register, {:fetch, :n}) * call(:register, {:fetch, :val}))})
    if call(:register, {:fetch, :continue}) == :done do
      call(:register, {:fetch, :val})
    else
      after_fact()
    end
  end


  use GenServer

  @impl GenServer
  def init(state), do: {:ok, state}
  @impl GenServer
  def handle_call({:assign, reg, value}, _from, state) do
    IO.inspect {state, reg, value}
    new_state = %{state | reg => value}
    {:reply, nil, new_state}
  end
  def handle_call({:save, reg}, _from, state) do
    IO.inspect state
    new_state = %{state | stack: [Map.get(state, reg) | state.stack]}
    {:reply, nil, new_state}
  end
  def handle_call({:restore, :n}, _from, state) do
    IO.inspect state
    top = Enum.at(Map.get(state, :stack), 0)
    {:reply, nil, %{state | n: top, stack: state.stack -- [top]}}
  end
  def handle_call({:restore, :continue}, _from, state) do
    IO.inspect state
    top = Enum.at(Map.get(state, :stack), 0)
    {:reply, nil, %{state | continue: top, stack: state.stack -- [top]}}
  end
  def handle_call({:fetch, reg}, _from, state), do: {:reply, Map.get(state, reg), state}
  def handle_call(:raw, _from, state), do: {:reply, state, state}
end

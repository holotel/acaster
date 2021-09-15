defmodule Acaster.MatcherServer.Ticket do
  defstruct [:id, :player]
end

defmodule Acaster.MatcherServer.Game do
  defstruct [:id, :black, :white]
end

defmodule Acaster.MatcherServer do
  use GenServer

  alias __MODULE__
  alias Acaster.MatcherServer.Game
  alias Acaster.MatcherServer.Ticket
  alias Phoenix.PubSub

  # Client

  def start_link() do
    GenServer.start_link(MatcherServer, :ok, [])
  end

  def register(ms, p) do
    GenServer.call(ms, {:register, p})
  end

  def unregister(ms, t) do
    GenServer.call(ms, {:unregister, t})
  end

  def list(ms) do
    GenServer.call(ms, :list)
  end

  def run_wave(ms) do
    GenServer.cast(ms, :run_wave)
  end

  ### Server

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  def split_evens(l) when rem(length(l), 2) == 0, do: {l, []}
  def split_evens([r | vs]), do: {vs, [r]}

  @impl true
  def handle_call({:register, p}, _from, state) do
    t = %Ticket{id: MonoID.gen(), player: p}
    {:reply, t, [t | state]}
  end

  @impl true
  def handle_call({:unregister, t}, _from, state) do
    case Enum.find(state, fn e -> e == t end) do
      nil -> {:reply, :not_found, state}
      _ -> {:reply, :ok, state |> Enum.filter(fn e -> e != t end)}
    end
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:run_wave, state) do
    {vs, r} = split_evens(state)

    vs
    |> Enum.chunk_every(2)
    |> Enum.each(fn [ta, tb] ->
      [b, w] = Enum.shuffle([ta.player, tb.player])
      game = %Game{id: MonoID.gen(), black: b, white: w}
      PubSub.broadcast(Acaster.PubSub, "ticket::#{ta.id}", {:matched, game})
      PubSub.broadcast(Acaster.PubSub, "ticket::#{tb.id}", {:matched, game})
    end)

    {:noreply, r}
  end
end

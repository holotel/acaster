defmodule Acaster.MatcherServer.Ticket do
  defstruct [:id, :matcher, :player]

  def unregister(t) do
    GenServer.call({:via, :swarm, t.matcher}, {:unregister, t})
  end
end

defmodule Acaster.MatcherServer do
  use GenServer

  alias __MODULE__
  alias Phoenix.PubSub

  alias Acaster.BoardState
  alias Acaster.GameServer
  alias Acaster.MatcherServer.Ticket
  alias Acaster.Game.FischerClock
  alias Acaster.Game.TimeControl

  # Client
  def spawn(%{name: name} = config) do
    case Swarm.register_name(
           name,
           DynamicSupervisor,
           :start_child,
           [Acaster.MatcherSupervisor, {GenServer, {MatcherServer, config}}]
         ) do
      {:ok, pid} ->
        :ok = Swarm.join(:matcher_server, pid)
        {:ok, pid}

      {:error, e} ->
        {:error, e}
    end
  end

  def child_spec(opts) do
    name = Keyword.get(opts, :name, GameServer)
    player = Keyword.fetch!(opts, :player)

    %{
      id: "#{GameServer}_#{name}",
      start: {GameServer, :start_link, [name, player]},
      shutdown: 10_000,
      restart: :transient
    }
  end

  def start_link(config) do
    GenServer.start_link(MatcherServer, config)
  end

  def register(p) do
    pid = Enum.random(Swarm.members(:matcher_server))
    GenServer.call(pid, {:register, p})
  end

  def register(name, p) do
    GenServer.call({:via, :swarm, name}, {:register, p})
  end

  def unregister(name, t) do
    GenServer.call({:via, :swarm, name}, {:unregister, t})
  end

  def list(name) do
    GenServer.call({:via, :swarm, name}, :list)
  end

  def run_wave(name) do
    GenServer.cast({:via, :swarm, name}, :run_wave)
  end

  ### Server
  @impl true
  def init(%{name: name}) do
    Process.send_after(self(), :run_wave, 1_000)
    {:ok, {name, []}}
  end

  def split_evens(l) when rem(length(l), 2) == 0, do: {l, []}
  def split_evens([r | vs]), do: {vs, [r]}

  @impl true
  def handle_call({:register, p}, _from, {name, ts}) do
    case Enum.find(ts, fn e -> e.player == p end) do
      nil ->
        t = %Ticket{id: MonoID.gen(), matcher: name, player: p}
        {:reply, t, {name, [t | ts]}}

      t ->
        {:reply, t, {name, ts}}
    end
  end

  @impl true
  def handle_call({:unregister, t}, _from, {name, ts}) do
    case Enum.find(ts, fn e -> e == t end) do
      nil -> {:reply, :not_found, {name, ts}}
      _ -> {:reply, :ok, ts |> Enum.filter(fn e -> e != t end)}
    end
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:run_wave, {name, ts}) do
    IO.puts("wave ran")
    {vs, r} = split_evens(ts)

    vs
    |> Enum.chunk_every(2)
    |> Enum.each(fn [ta, tb] ->
      [b, w] = Enum.shuffle([ta.player, tb.player])

      bs = %BoardState{
        board: Bitboard.standard(),
        turn: :black,
        tc: %TimeControl{
          black: %FischerClock{remaining: 5 * 60_000},
          white: %FischerClock{remaining: 5 * 60_000}
        },
        black: b,
        white: w
      }

      name = MonoID.gen()
      {:ok, _pid} = GameServer.start_link({name, bs})
      PubSub.broadcast(Acaster.PubSub, "ticket::#{ta.id}", {:matched, name})
      PubSub.broadcast(Acaster.PubSub, "ticket::#{tb.id}", {:matched, name})

      Process.send_after(self(), :run_wave, 1_000)
      {:noreply, {name, ts}}
    end)

    {:noreply, {name, r}}
  end
end

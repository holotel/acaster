defmodule Acaster.BoardState do
  defstruct [:board, :turn, :tc, :black, :white]
end

defmodule Acaster.GameServer do
  use GenStateMachine

  alias __MODULE__
  # alias Phoenix.PubSub
  alias Acaster.Game.TimeControl
  alias Acaster.BoardState

  ### Client
  def start_link({name, %BoardState{} = state}) do
    case Swarm.register_name(
           name,
           DynamicSupervisor,
           :start_child,
           [Acaster.MatcherSupervisor, {GenStateMachine, {GameServer, state}}]
         ) do
      {:ok, pid} ->
        :ok = Swarm.join(:matcher_server, pid)
        {:ok, pid}

      {:error, e} ->
        {:error, e}
    end
  end

  ### Server
  def flip(:black), do: :white
  def flip(:white), do: :black

  def next_mover(board, prev) do
    cond do
      moves = Bitboard.moves_for(board, flip(prev)) != 0 -> {flip(prev), moves}
      moves = Bitboard.moves_for(board, prev) != 0 -> {prev, moves}
      true -> :none
    end
  end

  defp winner(%Bitboard{} = board) do
    b = board |> Bitboard.points(:black)
    w = board |> Bitboard.points(:white)

    cond do
      b == w -> :draw
      b > w -> :black
      b < w -> :white
    end
  end

  def vote_start(name, c) do
    GenStateMachine.cast({:via, :swarm, name}, {:vote_start, c})
  end

  def vote_cancel(name, c) do
    GenStateMachine.cast({:via, :swarm, name}, {:vote_cancel, c})
  end

  def put(name, pos, c) do
    GenStateMachine.cast({:via, :swarm, name}, {:put, pos, c})
  end

  # Server
  @impl true
  def init(bs) do
    Process.send_after(self(), :commence_timeout, 20_000)
    {:ok, :not_started, {bs, []}}
  end

  @impl true
  def handle_event(:info, :commence_timeout, :not_started, _) do
    {:next_state, :cancelled, nil}
  end

  @impl true
  def handle_event(:cast, {:vote_start, p}, :not_started, {bs, []}) do
    {:next_state, :not_started, {bs, [p]}}
  end

  @impl true
  def handle_event(:cast, {:vote_start, p}, :not_started, %{config: config, acks: [q]})
      when p != q do
    {:next_state, :playing, %{game: config, history: []}}
  end

  @impl true
  def handle_event(:info, {:vote_cancel, _}, :not_started, _) do
    {:next_state, :cancelled, nil}
  end

  @impl true
  def handle_event(
        :info,
        {:turn_timeout, board},
        :playing,
        {%BoardState{:board => board} = bs, h}
      ) do
    {:next_state, {:terminated, :timeout, flip(bs.turn)}, {bs, h}}
  end

  @impl true
  def handle_event({:call, _}, {:put, pos, turn}, :playing, {%{:turn => turn} = g, h}) do
    {:ok, board} = g.board |> Bitboard.put(pos, turn)
    {:ok, tc, _} = g.tc |> TimeControl.stop(turn)

    case next_mover(board, turn) do
      :none ->
        {
          :next_state,
          {:terminated, :done, winner(board)},
          {%BoardState{g | :board => board, :tc => tc, :turn => :none}, [{g, pos, turn} | h]}
        }

      {next, _} ->
        {:ok, tc, rem} = tc |> TimeControl.start(next)
        Process.send_after(self(), {:turn_timeout, board}, rem)

        {
          :next_state,
          :playing,
          {%BoardState{g | :board => board, :tc => tc, :turn => next}, [{g, pos, turn} | h]}
        }
    end
  end
end

defmodule Acaster.GameInfo do
  defstruct [:initial]
end

defmodule Acaster.GameServer do
  use GenStateMachine, callback_mode: [:handle_event_function, :state_enter]

  alias __MODULE__
  # alias Phoenix.PubSub
  alias Acaster.Game.TimeControl

  # Client

  def start_link(opts) do
    GenStateMachine.start_link(GameServer, {:not_started, opts})
  end

  ### Server
  def flip(:black), do: :white
  def flip(:white), do: :black

  def mover_of(board, prev) do
    cond do
      moves = Bitboard.moves_for(board, flip(prev)) != 0 -> {flip(prev), moves}
      moves = Bitboard.moves_for(board, prev) != 0 -> {prev, moves}
      true -> :none
    end
  end

  @impl true
  def init({:not_started, game}) do
    {:ok, :not_started, {game, nil}}
  end

  @impl true
  def handle_event(:cast, {:start, p}, :not_started, {game, nil}) do
    {:next_state, :not_started, {game, p}}
  end

  @impl true
  def handle_event(:cast, {:start, p}, :not_started, {_, q}) when p == q do
    :keep_state_and_data
  end

  @impl true
  def handle_event(:cast, {:start, p}, :not_started, {game, q}) when p != q do
    {:next_state, :playing, %{game: game, history: []}}
  end

  @impl true
  def handle_event(
        {:call, _},
        {:emplace, pos, turn},
        :playing,
        {%{:turn => turn} = g, h}
      ) do
    {:ok, board} = g.board |> Bitboard.emplace(pos, turn)

    case mover_of(board, turn) do
      :none ->
        {:done, {%{board: board, tc: g.tc |> TimeControl.stop(turn)}, [{g, pos, turn} | h]}}

      {next, _} ->
        {
          :playing,
          %{
            board: board,
            tc: g.tc |> TimeControl.stop(turn),
            turn: next
          }
        }
    end
  end

  def handle_event(:enter, _, :done, {game, h}) do
    :keep_state_and_data
  end
end

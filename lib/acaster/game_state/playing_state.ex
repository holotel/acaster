defmodule Acaster.GameState.PlayingState do
  alias __MODULE__
  alias Bitboard

  defstruct [:board, :tc, :turn]

  def flip(:black), do: :white
  def flip(:white), do: :black

  def mover_of(b, p) do
    cond do
      moves = Bitboard.moves_for(b, flip(p)) != 0 -> {flip(p), moves}
      moves = Bitboard.moves_for(b, p) != 0 -> {p, moves}
      true -> :none
    end
  end
end

defimpl Acaster.GameState, for: Acaster.GameState.PlayingState do
  alias Acaster.GameState.DoneState
  alias Acaster.Game.TimeControl
  alias Acaster.GameState.PlayingState

  def emplace(%PlayingState{:board => b, :tc => tc, :turn => t}, p) when t in [:black, :white] do
    {:ok, b} = b |> Bitboard.emplace(p, t)

    case PlayingState.mover_of(b, t) do
      :none ->
        %DoneState{board: b, tc: tc |> TimeControl.stop(t)}

      {next, _} ->
        %PlayingState{
          board: b,
          tc: tc |> TimeControl.stop(t) |> TimeControl.start(next),
          turn: next
        }
    end
  end

  def status(_), do: :playing
  def start(_), do: throw("Illegal Action")
end

defimpl String.Chars, for: Acaster.GameState.PlayingState do
  def to_string(s), do: s.board |> Bitboard.to_string(s.turn)
end

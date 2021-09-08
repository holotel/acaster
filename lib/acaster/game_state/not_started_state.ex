defmodule Acaster.GameState.NotStartedState do
  defstruct [:board, :tc, :first]
end

defimpl Acaster.GameState, for: Acaster.GameState.NotStartedState do
  alias Acaster.Game.TimeControl
  alias Acaster.GameState.NotStartedState
  alias Acaster.GameState.PlayingState

  def emplace(_, _), do: throw("Illegal Action")
  def status(_), do: :not_started

  def start(%NotStartedState{:board => board, :tc => tc, :first => first}) do
    %PlayingState{board: board, tc: tc |> TimeControl.start(first), turn: first}
  end
end

defimpl String.Chars, for: Acaster.GameState.NotStartedState do
  def to_string(s), do: s.board |> Bitboard.to_string(s.first)
end

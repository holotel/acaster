defmodule Acaster.GameState.DoneState do
  defstruct [:board, :tc]
end

defimpl Acaster.GameState, for: Acaster.GameState.DoneState do
  def emplace(_, _), do: throw("Illegal Action")
  def status(_), do: :done
  def start(_), do: throw("Illegal Action")
end

defimpl String.Chars, for: Acaster.GameState.DoneState do
  def to_string(s), do: s.board |> Bitboard.to_string(nil)
end

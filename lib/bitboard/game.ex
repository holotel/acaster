defmodule Bitboard.Game do
  defstruct [:board, :turn]
  alias __MODULE__

  def standard(), do: %Game{board: Bitboard.standard(), turn: :black}

  defp flip(:black), do: :white
  defp flip(:white), do: :black

  def next_mover(%Bitboard{} = board, prev) when prev in [:black, :white] do
    cond do
      moves = Bitboard.moves_for(board, flip(prev)) != 0 -> {flip(prev), moves}
      moves = Bitboard.moves_for(board, prev) != 0 -> {prev, moves}
      true -> :none
    end
  end

  def put(%Game{board: board, turn: turn}, pos) do
    {:ok, board} = board |> Bitboard.put(pos, turn)

    case next_mover(board, turn) do
      :none -> %Game{board: board, turn: :none}
      {next, _} -> %Game{board: board, turn: next}
    end
  end

  def put(%Game{turn: :black} = game, pos, :black), do: put(game, pos)
  def put(%Game{turn: :white} = game, pos, :white), do: put(game, pos)

  def over?(%Game{turn: :none}), do: true
  def over?(%Game{}), do: false

  def winner(%Game{board: board}) do
    case {Bitboard.points(board, :black), Bitboard.points(board, :white)} do
      {b, w} when b == w -> :draw
      {b, w} when b > w -> :black
      {b, w} when b < w -> :white
    end
  end
end

defimpl String.Chars, for: Bitboard.Game do
  def to_string(%Bitboard.Game{board: b, turn: t}), do: b |> Bitboard.to_string(t)
end

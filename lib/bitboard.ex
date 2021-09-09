defmodule Bitboard do
  use Rustler, otp_app: :acaster, crate: "bitboard"
  use Bitwise

  defstruct [:blacks, :whites]

  def empty(), do: :erlang.nif_error(:nif_not_loaded)
  def standard(), do: :erlang.nif_error(:nif_not_loaded)

  def emplace_black(_board, _pos), do: :erlang.nif_error(:nif_not_loaded)
  def emplace_white(_board, _pos), do: :erlang.nif_error(:nif_not_loaded)
  def emplace(b, p, :black), do: emplace_black(b, p)
  def emplace(b, p, :white), do: emplace_white(b, p)

  def put_black(_board, _pos), do: :erlang.nif_error(:nif_not_loaded)
  def put_white(_board, _pos), do: :erlang.nif_error(:nif_not_loaded)
  def put(b, p, :black), do: put_black(b, p)
  def put(b, p, :white), do: put_white(b, p)

  def remove(_board, _pos), do: :erlang.nif_error(:nif_not_loaded)

  def moves_for_black(_board), do: :erlang.nif_error(:nif_not_loaded)
  def moves_for_white(_board), do: :erlang.nif_error(:nif_not_loaded)
  def moves_for(b, :black), do: moves_for_black(b)
  def moves_for(b, :white), do: moves_for_white(b)

  def is_legal_move_black(_board, _pos), do: :erlang.nif_error(:nif_not_loaded)
  def is_legal_move_white(_board, _pos), do: :erlang.nif_error(:nif_not_loaded)
  def legal_move?(b, p, :black), do: is_legal_move_black(b, p)
  def legal_move?(b, p, :white), do: is_legal_move_white(b, p)

  def spread(0), do: []
  def spread(b), do: [b &&& -b | spread(b &&& b - 1)]

  def points(b), do: %{black: length(spread(b.blacks)), white: length(spread(b.whites))}
  def points(b, :black), do: points(b).black
  def points(b, :white), do: points(b).white

  def to_string(b, t) do
    unfold = fn b -> Stream.unfold(b, fn v -> {rem(v, 2), div(v, 2)} end) |> Enum.take(64) end

    board =
      Enum.zip(
        Enum.zip(unfold.(b.blacks), unfold.(b.whites)),
        Enum.zip(unfold.(Bitboard.moves_for(b, :black)), unfold.(Bitboard.moves_for(b, :white)))
      )
      |> Enum.map(fn
        {{1, 0}, {0, 0}} -> " ■ "
        {{0, 1}, {0, 0}} -> " □ "
        {{0, 0}, {1, _}} when t == :black -> " ▪ "
        {{0, 0}, {_, 1}} when t == :white -> " ▫ "
        _ -> " · "
      end)
      |> Enum.chunk_every(8)
      |> Enum.map(&Enum.join/1)
      |> Enum.zip(1..8)
      |> Enum.map(fn {r, i} -> "#{i} #{r}" end)
      |> Enum.join("\n")

    "   A  B  C  D  E  F  G  H \n#{board}\n"
  end
end

defimpl String.Chars, for: Bitboard do
  def to_string(b), do: b |> Bitboard.to_string(nil)
end

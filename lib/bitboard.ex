defmodule Bitboard do
  use Rustler, otp_app: :acaster, crate: "bitboard"
  use Bitwise

  defstruct blacks: 0, whites: 0

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

  def spread(0), do: []
  def spread(b), do: [b &&& -b | spread(bxor(b, b &&& -b))]

  def msb_p(1), do: 0
  def msb_p(v), do: 1 + msb_p(div(v, 2))
  def to_coor(v), do: {div(msb_p(v), 8), rem(msb_p(v), 8)}
  def from_coor({r, c}), do: 1 <<< (8 * r + c)
end

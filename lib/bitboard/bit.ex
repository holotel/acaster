defmodule Bitboard.Bit do
  use Bitwise

  defp msb_p(1), do: 0
  defp msb_p(v), do: 1 + msb_p(div(v, 2))

  def to_rc(v), do: {div(msb_p(v), 8), rem(msb_p(v), 8)}
  def from_rc({r, c}), do: 1 <<< (8 * r + c)

  def from_an(<<c, r>>) when c in ?A..?H and r in ?1..?8,
    do: 1 <<< (8 * (r - ?1) + (c - ?A))

  def from_an(<<c, r>>) when c in ?a..?h and r in ?1..?8,
    do: 1 <<< (8 * (r - ?1) + (c - ?a))

  def to_an(v) when is_integer(v) do
    {r, c} = to_rc(v)
    <<c + 0x41, r + 0x31>>
  end

  def sigil_a(s, []), do: from_an(s)
end

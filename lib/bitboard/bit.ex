defmodule Bitboard.Bit do
  use Bitwise

  defp msb_p(1), do: 0
  defp msb_p(v), do: 1 + msb_p(div(v, 2))

  def to_rc(v), do: {div(msb_p(v), 8), rem(msb_p(v), 8)}
  def from_rc({r, c}), do: 1 <<< (8 * r + c)

  def from_str(<<c, r>>) when c in 0x41..0x48 and r in 0x31..0x38,
    do: 1 <<< (8 * (r - 0x31) + (c - 0x41))

  def from_str(<<c, r>>) when c in 0x61..0x68 and r in 0x31..0x38,
    do: 1 <<< (8 * (r - 0x31) + (c - 0x61))

  def to_str(v) when is_integer(v) do
    {r, c} = to_rc(v)
    <<c + 0x41, r + 0x31>>
  end

  def sigil_b(s, []), do: from_str(s)

  def sigil_B(<<>>, []), do: []
  def sigil_B(<<c, r, rest::binary>>, []), do: [from_str(<<c, r>>) | sigil_B(rest, [])]
end

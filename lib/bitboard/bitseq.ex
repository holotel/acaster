defmodule Bitboard.Bitseq do
  alias Bitboard.Bit

  def from_ans(<<>>), do: []
  def from_ans(<<c, r, rest::binary>>), do: [Bit.from_an(<<c, r>>) | from_ans(rest)]

  def to_ans(vs), do: vs |> Enum.map(&Bit.to_an/1) |> Enum.join()

  def sigil_A(s, []), do: from_ans(s)
end

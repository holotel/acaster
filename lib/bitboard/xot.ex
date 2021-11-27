defmodule Bitboard.XotLoader do
  def load(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(&Bitboard.Bitseq.from_ans/1)
    |> Enum.with_index()
    |> Map.new(fn {v, i} -> {i, v} end)
  end
end

defmodule Bitboard.Xot do
  alias Bitboard.XotLoader

  @xot_large File.read!("priv/data/xot-large.txt") |> XotLoader.load()
  @xot_small File.read!("priv/data/xot-small.txt") |> XotLoader.load()

  def get(:large), do: @xot_large |> Map.to_list() |> Enum.sort() |> Enum.map(fn {_, v} -> v end)
  def get(:small), do: @xot_small |> Map.to_list() |> Enum.sort() |> Enum.map(fn {_, v} -> v end)

  defp random_map(map), do: Map.fetch!(map, Enum.random(0..(map_size(map) - 1)))
  def random(:large), do: random_map(@xot_large)
  def random(:small), do: random_map(@xot_small)
end

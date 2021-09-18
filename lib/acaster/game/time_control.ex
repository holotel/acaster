defmodule Acaster.Game.TimeControl do
  alias __MODULE__
  alias Acaster.Game.Clock

  defstruct([:black, :white])

  def start(%TimeControl{:black => b, :white => w}, :black) do
    {:ok, b, rem} = b |> Clock.start()
    {:ok, %TimeControl{black: b, white: w}, rem}
  end

  def start(%TimeControl{:black => b, :white => w}, :white) do
    {:ok, w, rem} = w |> Clock.start()
    {:ok, %TimeControl{black: b, white: w}, rem}
  end

  def stop(%TimeControl{:black => b, :white => w}, :black) do
    {:ok, b, taken} = b |> Clock.stop()
    {:ok, %TimeControl{black: b, white: w}, taken}
  end

  def stop(%TimeControl{:black => b, :white => w}, :white) do
    {:ok, w, taken} = w |> Clock.stop()
    {:ok, %TimeControl{black: b, white: w}, taken}
  end
end

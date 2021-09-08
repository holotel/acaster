defmodule Acaster.Game.TimeControl do
  alias __MODULE__
  alias Acaster.Game.Clock

  defstruct([:black, :white])

  def start(%TimeControl{:black => b, :white => w}, :black) do
    {:ok, b, _} = b |> Clock.start()
    %TimeControl{black: b, white: w}
  end

  def start(%TimeControl{:black => b, :white => w}, :white) do
    {:ok, w, _} = w |> Clock.start()
    %TimeControl{black: b, white: w}
  end

  def stop(%TimeControl{:black => b, :white => w}, :black) do
    {:ok, b, _} = b |> Clock.stop()
    %TimeControl{black: b, white: w}
  end

  def stop(%TimeControl{:black => b, :white => w}, :white) do
    {:ok, w, _} = w |> Clock.stop()
    %TimeControl{black: b, white: w}
  end

  def flag?(%TimeControl{:black => b, :white => w}), do: b |> Clock.flag?() or w |> Clock.flag?()
end

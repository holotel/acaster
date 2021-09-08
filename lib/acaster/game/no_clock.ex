defmodule Acaster.Game.NoClock do
  defstruct []
end

defimpl Acaster.Game.Clock, for: Acaster.Game.NoClock do
  def start(clock), do: {:ok, clock, 24 * 60 * 60 * 1000}

  def stop(clock), do: {:ok, clock, 0}

  def flag?(_), do: false
end

defmodule Acaster.Game.FischerClock do
  alias __MODULE__
  defstruct [:remaining, :increment, :grace, :start]

  def stop(%FischerClock{:start => nil}, _), do: {:error, "not started"}

  def stop(%FischerClock{:remaining => 0} = c, _), do: {:timeout, c}

  def stop(%FischerClock{:remaining => rem, :grace => grace, :start => start} = c, t)
      when rem + grace <= t - start,
      do: {:timeout, %FischerClock{c | :remaining => 0, :start => nil}}

  def stop(c, t) do
    taken = max(0, t - c.start - c.grace)

    {
      :ok,
      %FischerClock{c | :remaining => c.remaining + c.increment - taken, :start => nil},
      taken
    }
  end
end

defimpl Acaster.Game.Clock, for: Acaster.Game.FischerClock do
  alias Acaster.Game.FischerClock

  def start(clock) do
    {
      :ok,
      %FischerClock{clock | :start => System.monotonic_time(:millisecond)},
      clock.remaining
    }
  end

  def stop(clock) do
    FischerClock.stop(clock, System.monotonic_time(:millisecond))
  end

  def flag?(%FischerClock{:remaining => rem}), do: rem == 0
end

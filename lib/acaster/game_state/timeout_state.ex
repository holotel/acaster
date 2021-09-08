defmodule Acaster.GameState.TimeoutState do
  defstruct [:board, :tc]
end

defimpl Acaster.GameState, for: Acaster.GameState.TimeoutState do
  def emplace(_, _), do: throw("Illegal Action")
  def status(_), do: :timeout
  def start(_), do: throw("Illegal Action")
end

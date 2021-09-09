defmodule Glicko do
  use Rustler, otp_app: :acaster, crate: "glicko"
  defstruct [:mu, :phi, :sigma]

  def simple(_rating, _std), do: :erlang.nif_error(:nif_not_loaded)
  def update(_g, _ms), do: :erlang.nif_error(:nif_not_loaded)

  def rating(_g), do: :erlang.nif_error(:nif_not_loaded)
  def stdev(_g), do: :erlang.nif_error(:nif_not_loaded)
end

defmodule Glicko.Match do
  defstruct [:o, :r]
end

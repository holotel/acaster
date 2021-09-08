defmodule Acaster.Delay do
  def delay(v, t) do
    Process.sleep(t)
    v
  end
end

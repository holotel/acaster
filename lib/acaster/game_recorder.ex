defmodule Acaster.GameRecorder do
  def report(g, h) do
    IO.inspect(g.black, g.white)
    IO.puts("#{g.board}")
    IO.inspect(h)
  end
end

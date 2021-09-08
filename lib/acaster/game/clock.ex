defprotocol Acaster.Game.Clock do
  def start(c)
  def stop(c)
  def flag?(c)
end

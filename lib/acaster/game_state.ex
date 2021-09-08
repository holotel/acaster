defprotocol Acaster.GameState do
  def emplace(s, p)
  def status(s)
  def start(s)
end

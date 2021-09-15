defmodule Acaster.GameSupervisor do
  def start_game(%{id: id} = config) do
    Swarm.register_name(
      id,
      DynamicSupervisor,
      :start_child,
      [Acaster.GameSupervisor, {GameServer, config}]
    )
  end
end

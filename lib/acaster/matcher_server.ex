defmodule Acaster.MatcherServer do
  @moduledoc """
  A GenServer that manages and models the state for a specific game instance.
  """
  use GenServer
  require Logger
  alias Phoenix.PubSub
  alias Acaster.GameState.NotStartedState
  alias Acaster.GameState

  # Client

  @doc """
  Start a GameServer with the specified game_code as the name.
  """
  def start_link(opts) do
    GenServer.start_link(GameServer, :ok, opts)
  end

  ###
  ### Server
  ###

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  @impl true
  def handle_call({:register, id}, _from, state) do
    {:reply, [id | state]}
  end

  @impl true
  def handle_info(:run, state) do
    # Shutdown the game server when it's been inactive for too long.
    Logger.info("Game #{inspect(state.board)} was ended for inactivity")
    {:stop, :normal, state}
  end

  # def broadcast_game_state(%GameState{} = state) do
  #   PubSub.broadcast(Tictac.PubSub, "game:#{state.code}", {:game_state, state})
  # end
end

defmodule Acaster.MatcherServer.Player do
end

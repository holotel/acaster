defmodule Acaster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Start the Ecto repository
      Acaster.Repo,
      # Start the Telemetry supervisor
      AcasterWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Acaster.PubSub},
      # Setup clustering
      {Cluster.Supervisor, [topologies, [name: Acaster.ClusterSupervisor]]},
      # Setup game supervisor
      {DynamicSupervisor, name: Acaster.GameSupervisor, strategy: :one_for_one},
      # Start the Endpoint (http/https)
      AcasterWeb.Endpoint
      # Start a worker by calling: Acaster.Worker.start_link(arg)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Acaster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AcasterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule TickeMaster.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TickeMasterWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:ticke_master, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TickeMaster.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TickeMaster.Finch},
      # Start a worker by calling: TickeMaster.Worker.start_link(arg)
      # {TickeMaster.Worker, arg},
      # Start to serve requests, typically the last entry
      TickeMasterWeb.Endpoint,
      {TickeMaster.TicketServer, 10}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TickeMaster.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TickeMasterWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

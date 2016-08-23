defmodule Dasher do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Dasher.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Dasher.Endpoint, []),
      # Start your own worker by calling: Dasher.Worker.start_link(arg1, arg2, arg3)
      # worker(Dasher.Worker, [arg1, arg2, arg3]),
      Dasher.MetricsEventHandler.child_spec,
      worker(Dasher.Metrics, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Dasher.Supervisor]
    ret = with {:ok, pid} <- Supervisor.start_link(children, opts),
         :ok <- Dasher.MetricsEventHandler.register,
         do: {:ok, pid}

    ret
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Dasher.Endpoint.config_change(changed, removed)
    :ok
  end
end

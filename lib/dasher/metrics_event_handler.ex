defmodule Dasher.MetricsEventHandler do
  use GenEvent

  @name :metrics_event_handler

  def child_spec do
    Supervisor.Spec.worker(GenEvent, [[name: @name]])
  end

  def update(event) do
    GenEvent.sync_notify(@name, event)
  end

  def register do
    GenEvent.add_handler(@name, __MODULE__, nil)
  end

  # Callback

  def handle_event({:refresh, %{name: _, value: _} = data}, parent) do
    Dasher.Endpoint.broadcast(
      "metric:lobby",
      "refresh",
      data
    )

    {:ok, parent}
  end
end

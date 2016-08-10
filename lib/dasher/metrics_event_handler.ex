defmodule Dasher.MetricsEventHandler do
  use GenEvent

  def handle_event({:refresh, %{name: name, value: value} = data}, parent) do
    Dasher.Endpoint.broadcast(
      "metric:lobby",
      "refresh",
      data
    )

    {:ok, parent}
  end
end

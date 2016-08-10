defmodule Dasher.MetricEventHandlerTest do
  use Dasher.ChannelCase

  setup do
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(Dasher.MetricChannel, "metric:lobby")

    {:ok, events} = GenEvent.start_link
    :ok = GenEvent.add_handler(events, Dasher.MetricsEventHandler, self())

    {:ok, events: events, socket: socket}
  end

  test "handles :refresh events by broadcasting to the metrics channel", %{events: events, socket: socket} do
    GenEvent.sync_notify(events, {:refresh, %{name: "toto", value: 42}})
    assert_broadcast "refresh", %{name: "toto", value: 42}
  end
end

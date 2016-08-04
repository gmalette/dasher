defmodule Dasher.MetricChannelTest do
  use Dasher.ChannelCase

  alias Dasher.MetricChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{})
      |> subscribe_and_join(MetricChannel, "metric:lobby")

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end
end

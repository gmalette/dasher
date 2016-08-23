defmodule Dasher.MetricTest do
  use ExUnit.Case

  alias Dasher.Metrics

  defmodule Forwarder do
    use GenEvent

    def handle_event(event, parent) do
      send(parent, event)
      {:ok, parent}
    end
  end

  setup do
    {:ok, _} = Metrics.start_link
    GenEvent.add_mon_handler(:metrics_event_handler, Forwarder, self())

    :ok
  end

  test "reading unknown metric returns an error", %{} do
    assert :error == Metrics.get("toto")
  end

  test "can add values", %{} do
    assert :ok == Metrics.add("toto", :value, 42)
    assert {:ok, {:value, 42}} == Metrics.get("toto")
  end

  test "can add gauges", %{} do
    assert :ok == Metrics.add("toto", :gauge, 42)
    assert {:ok, {:gauge, 42}} == Metrics.get("toto")
  end

  test "can't add invalid gauges", %{} do
    assert :error == Metrics.add("toto", :gauge, "abc")
  end

  test "can add histograms", %{} do
    values = [
      %{x: 0, y: 10},
      %{x: 1, y: 7},
      %{x: 2, y: 5},
      %{x: 3, y: 3},
    ]
    assert :ok == Metrics.add("toto", :histogram, values)
    assert {:ok, {:histogram, values}} == Metrics.get("toto")
  end

  test "can't add invalid histograms", %{} do
    values = [
      %{a: 0, y: 10},
    ]
    assert :error == Metrics.add("toto", :histogram, values)

    values = [
      %{x: 0, y: "a"},
    ]
    assert :error == Metrics.add("toto", :histogram, values)

    values = [
      %{x: 0, y: 10, z: 10},
    ]
    assert :error == Metrics.add("toto", :histogram, values)
  end

  test "can add arbitrary data", %{} do
    assert :ok == Metrics.add("toto", :arbitrary, 42)
    assert :ok == Metrics.add("toto", :arbitrary, [42])
    assert :ok == Metrics.add("toto", :arbitrary, %{a: 42})
  end

  test "can't add unknown values", %{} do
    assert :error == Metrics.add("toto", :blog, "my personal blog")
  end

  test "adding a metric sends a :refresh event", %{} do
    assert :ok == Metrics.add("toto", :value, 42)
    assert_received {:refresh, %{name: "toto", value: 42}}
  end
end

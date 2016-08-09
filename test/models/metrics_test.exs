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
    {:ok, events} = GenEvent.start_link
    {:ok, pid} = Metrics.start_link(events)
    GenEvent.add_mon_handler(events, Forwarder, self())

    {:ok, pid: pid, events: events}
  end

  test "reading unknown metric returns an error", %{pid: pid} do
    assert :error == Metrics.get(pid, "toto")
  end

  test "can add values", %{pid: pid} do
    assert :ok == Metrics.add(pid, "toto", :value, 42)
    assert {:ok, {:value, 42}} == Metrics.get(pid, "toto")
  end

  test "can add gauges", %{pid: pid} do
    assert :ok == Metrics.add(pid, "toto", :gauge, 42)
    assert {:ok, {:gauge, 42}} == Metrics.get(pid, "toto")
  end

  test "can't add invalid gauges", %{pid: pid} do
    assert :error == Metrics.add(pid, "toto", :gauge, "abc")
  end

  test "can add histograms", %{pid: pid} do
    values = [
      %{x: 0, y: 10},
      %{x: 1, y: 7},
      %{x: 2, y: 5},
      %{x: 3, y: 3},
    ]
    assert :ok == Metrics.add(pid, "toto", :histogram, values)
    assert {:ok, {:histogram, values}} == Metrics.get(pid, "toto")
  end

  test "can't add invalid histograms", %{pid: pid} do
    values = [
      %{a: 0, y: 10},
    ]
    assert :error == Metrics.add(pid, "toto", :histogram, values)

    values = [
      %{x: 0, y: "a"},
    ]
    assert :error == Metrics.add(pid, "toto", :histogram, values)

    values = [
      %{x: 0, y: 10, z: 10},
    ]
    assert :error == Metrics.add(pid, "toto", :histogram, values)
  end

  test "can add arbitrary data", %{pid: pid} do
    assert :ok == Metrics.add(pid, "toto", :arbitrary, 42)
    assert :ok == Metrics.add(pid, "toto", :arbitrary, [42])
    assert :ok == Metrics.add(pid, "toto", :arbitrary, %{a: 42})
  end

  test "can't add unknown values", %{pid: pid} do
    assert :error == Metrics.add(pid, "toto", :blog, "my personal blog")
  end

  test "adding a metric sends a :refresh event", %{pid: pid} do
    assert :ok == Metrics.add(pid, "toto", :value, 42)
    assert_received {:refresh, "toto"}
  end
end

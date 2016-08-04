defmodule Dasher.MetricTest do
  use ExUnit.Case

  alias Dasher.Metrics

  setup do
    {:ok, pid} = Dasher.Metrics.start_link

    {:ok, pid: pid}
  end

  test "reading unknown metric returns an error", %{pid: pid} do
    assert :error == Dasher.Metrics.get(pid, "toto")
  end

  test "can add values", %{pid: pid} do
    assert :ok == Dasher.Metrics.add(pid, "toto", :value, 42)
    assert {:ok, {:value, 42}} == Dasher.Metrics.get(pid, "toto")
  end

  test "can add histograms", %{pid: pid} do
    values = [
      %{x: 0, y: 10},
      %{x: 1, y: 7},
      %{x: 2, y: 5},
      %{x: 3, y: 3},
    ]
    assert :ok == Dasher.Metrics.add(pid, "toto", :histogram, values)
    assert {:ok, {:histogram, values}} == Dasher.Metrics.get(pid, "toto")
  end

  test "can't add invalid histograms", %{pid: pid} do
    values = [
      %{a: 0, y: 10},
    ]
    assert :error == Dasher.Metrics.add(pid, "toto", :histogram, values)

    values = [
      %{x: 0, y: "a"},
    ]
    assert :error == Dasher.Metrics.add(pid, "toto", :histogram, values)
  end

  test "can add arbitrary data", %{pid: pid} do
    assert :ok == Dasher.Metrics.add(pid, "toto", :arbitrary, 42)
    assert :ok == Dasher.Metrics.add(pid, "toto", :arbitrary, [42])
    assert :ok == Dasher.Metrics.add(pid, "toto", :arbitrary, %{a: 42})
  end

  test "can't add unknown values", %{pid: pid} do
    assert :error == Dasher.Metrics.add(pid, "toto", :blog, "my personal blog")
  end
end

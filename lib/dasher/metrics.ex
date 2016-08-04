defmodule Dasher.Metrics do
  use GenServer

  @table_name :dasher_data

  def start_link(events) do
    GenServer.start_link(__MODULE__, {events})
  end

  def add(pid, metric_name, data_type, data) do
    GenServer.call(pid, {:add, metric_name, data_type, data})
  end

  def get(pid, metric_name) do
    GenServer.call(pid, {:get, metric_name})
  end

  # callbacks

  def init({events}) do
    table = :ets.new(@table_name, [:named_table])
    {:ok, %{table: table, events: events}}
  end

  def handle_call({:add, metric_name, data_type, data}, _from, %{table: table, events: events} = state) do
    case validate_data_type(data_type, data) do
      :ok ->
        :ets.insert(table, {metric_name, {data_type, data}})
        GenEvent.sync_notify(events, {:refresh, metric_name})
        {:reply, :ok, state}
      :error ->
        {:reply, :error, state}
    end
  end

  def handle_call({:get, metric_name}, _from, %{table: table} = state) do
    ret = case :ets.lookup(table, metric_name) do
      [{^metric_name, data}] -> {:ok, data}
      [] -> :error
    end
    {:reply, ret, state}
  end

  def validate_data_type(:histogram, data) when is_list(data) do
    valid = data
    |> Enum.all?(fn(row) ->
      is_map(row) &&
      row |> Map.keys |> Enum.sort == [:x, :y] &&
      is_number(row[:y])
    end)

    case valid do
      false -> :error
      true -> :ok
    end
  end

  def validate_data_type(:value, data) do
    :ok
  end

  def validate_data_type(:arbitrary, data) do
    :ok
  end

  def validate_data_type(_, _) do
    :error
  end
end

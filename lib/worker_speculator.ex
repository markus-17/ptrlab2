defmodule WorkerSpeculator do
  use GenServer

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:check_msg_ref, msg_ref}, _, state_map) do
    case Map.get(state_map, msg_ref) do
      nil ->
        state_map = Map.put(state_map, msg_ref, true)
        {:reply, :ok, state_map}

      true ->
        {:reply, :late, state_map}
    end
  end

  def check_msg_ref(msg_ref) do
    GenServer.call(__MODULE__, {:check_msg_ref, msg_ref})
  end
end

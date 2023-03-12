defmodule Printer do
  use GenServer

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    {:ok, nil}
  end

  @impl true
  def handle_info(json, state) do
    IO.puts(json["message"]["tweet"]["text"])
    {:noreply, state}
  end
end

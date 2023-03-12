defmodule Printer do
  use GenServer

  def start_link({sleep_min, sleep_max}) do
    GenServer.start_link(__MODULE__, {sleep_min, sleep_max}, name: __MODULE__)
  end

  @impl true
  def init({sleep_min, sleep_max}) do
    {:ok, {sleep_min, sleep_max}}
  end

  @impl true
  def handle_info(json, {sleep_min, sleep_max}) do
    IO.puts(json["message"]["tweet"]["text"])
    sleep_min..sleep_max |> Enum.random() |> Process.sleep()
    {:noreply, {sleep_min, sleep_max}}
  end
end

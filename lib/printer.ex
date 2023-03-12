defmodule Printer do
  use GenServer

  def start_link(name, sleep_min, sleep_max) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, {name, sleep_min, sleep_max}, name: name)
  end

  @impl true
  def init({name, sleep_min, sleep_max}) do
    {:ok, {name, sleep_min, sleep_max}}
  end

  @impl true
  def handle_info(json, {name, sleep_min, sleep_max}) do
    text = json["message"]["tweet"]["text"] |> String.replace("\n", " ") |> String.slice(0, 45)
    IO.puts("#{name}: #{text}")
    sleep_min..sleep_max |> Enum.random() |> Process.sleep()
    {:noreply, {name, sleep_min, sleep_max}}
  end
end

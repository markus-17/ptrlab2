defmodule LoadBalancer do
  use GenServer

  def start_link(nr_of_printers) do
    IO.puts("LoadBalancer is going to start...")
    GenServer.start_link(__MODULE__, nr_of_printers, name: __MODULE__)
  end

  @impl true
  def init(nr_of_printers) do
    {:ok, {nr_of_printers}}
  end

  @impl true
  def handle_info("GO KILL YOURSELF", {nr_of_printers}) do
    printer_name = :"printer#{Enum.random(1..nr_of_printers)}"
    if Process.whereis(printer_name) != nil, do: send(printer_name, "GO KILL YOURSELF")
    {:noreply, {nr_of_printers}}
  end

  @impl true
  def handle_info(message, {nr_of_printers}) do
    hash_distribution_key = message["message"]["tweet"]["text"]
    current_printer = :crypto.hash(:sha256, hash_distribution_key) |> :binary.last() |> rem(3)
    printer_name = :"printer#{current_printer + 1}"
    if Process.whereis(printer_name) != nil, do: send(printer_name, message)
    {:noreply, {nr_of_printers}}
  end
end

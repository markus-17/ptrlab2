defmodule LoadBalancer do
  use GenServer

  def start_link(nr_of_printers) do
    IO.puts("LoadBalancer is going to start...")
    GenServer.start_link(__MODULE__, nr_of_printers, name: __MODULE__)
  end

  @impl true
  def init(nr_of_printers) do
    {:ok, {0, nr_of_printers}}
  end

  @impl true
  def handle_info(message, {current_printer, nr_of_printers}) do
    printer_name = :"printer#{current_printer + 1}"
    if Process.whereis(printer_name) != nil, do: send(printer_name, message)
    {:noreply, {rem(current_printer + 1, nr_of_printers), nr_of_printers}}
  end
end

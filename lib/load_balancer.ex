defmodule LoadBalancer do
  use GenServer

  def start_link(:ok) do
    IO.puts("LoadBalancer is going to start...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    {:ok, nil}
  end

  @impl true
  def handle_info("GO KILL YOURSELF", state) do
    # printer_name = :"printer#{Enum.random(1..nr_of_printers)}"
    # if Process.whereis(printer_name) != nil, do: send(printer_name, "GO KILL YOURSELF")
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    hash_distribution_key = message["message"]["tweet"]["text"]
    nr_of_printers = Supervisor.count_children(WorkerPoolSupervisor).specs
    current_printer = :crypto.hash(:sha256, hash_distribution_key) |> :binary.last() |> rem(nr_of_printers)
    message_ref = make_ref()

    Enum.each(0..2, fn i ->
      printer_id = rem(current_printer + i, nr_of_printers)
      printer_name = :"printer#{printer_id}"
      if Process.whereis(printer_name) != nil, do: send(printer_name, {message, message_ref})
    end)

    {:noreply, state}
  end
end

defmodule WorkerPoolSupervisor do
  use Supervisor

  def start_link(:ok) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      %{
        id: :printer1,
        start: {Printer, :start_link, [:printer1]}
      },
      %{
        id: :printer2,
        start: {Printer, :start_link, [:printer2]}
      },
      %{
        id: :printer3,
        start: {Printer, :start_link, [:printer3]}
      },
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

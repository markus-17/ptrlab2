defmodule MainSupervisor do
  use Supervisor

  def start_link(init_arg \\ :ok) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Printer, :ok},
      {Reader, {:reader1, "localhost:4000/tweets/1"}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

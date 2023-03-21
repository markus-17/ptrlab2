defmodule MainSupervisor do
  use Supervisor

  def start_link(init_arg \\ :ok) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {WorkerSpeculator, :ok},
      {WorkerPoolSupervisor, :ok},
      {LoadBalancer, :ok},
      %{
        id: :reader1,
        start: {Reader, :start_link, [:reader1, "localhost:4000/tweets/1"]}
      },
      %{
        id: :reader2,
        start: {Reader, :start_link, [:reader2, "localhost:4000/tweets/2"]}
      },
      {WorkerManager, [100, 3, 50, 50]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end

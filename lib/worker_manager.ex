defmodule WorkerManager do
  use GenServer

  def start_link([delay, min_workers, max_workers, task_per_worker]) do
    IO.puts("WorkerManager is going to start...")

    {:ok, pid} =
      GenServer.start_link(
        __MODULE__,
        {delay, min_workers, max_workers, task_per_worker},
        name: __MODULE__
      )

    Process.send_after(pid, :check, delay)
    {:ok, pid}
  end

  def init({delay, min_workers, max_workers, task_per_worker}) do
    {:ok, {delay, min_workers, max_workers, task_per_worker}}
  end

  defp get_worker_stats() do
    nr_of_workers = Supervisor.count_children(WorkerPoolSupervisor).specs

    nr_of_tasks =
      Enum.reduce(Supervisor.which_children(WorkerPoolSupervisor), 0, fn {_, pid, _, _}, acc ->
        {:message_queue_len, length} = Process.info(pid, :message_queue_len)
        acc + length
      end)

    {nr_of_tasks / nr_of_workers, nr_of_workers}
  end

  def handle_info(:check, {delay, min_workers, max_workers, task_per_worker}) do
    {avg_tasks, nr_of_workers} = get_worker_stats()

    IO.puts("\e[031mWorkerManager: An average of #{avg_tasks} tasks / worker was detected.\e[0m")

    cond do
      nr_of_workers > max_workers ->
        Supervisor.terminate_child(WorkerPoolSupervisor, :"printer#{nr_of_workers}")
        Supervisor.delete_child(WorkerPoolSupervisor, :"printer#{nr_of_workers}")

      nr_of_workers < min_workers ->
        Supervisor.start_child(WorkerPoolSupervisor, %{
          id: :"printer#{nr_of_workers + 1}",
          start: {Printer, :start_link, [:"printer#{nr_of_workers + 1}", 5, 50]}
        })

      avg_tasks > task_per_worker && nr_of_workers < max_workers ->
        Supervisor.start_child(WorkerPoolSupervisor, %{
          id: :"printer#{nr_of_workers + 1}",
          start: {Printer, :start_link, [:"printer#{nr_of_workers + 1}", 5, 50]}
        })
        IO.puts("\e[031mWorkerManager: printer#{nr_of_workers + 1} was added.\e[0m")

      avg_tasks < task_per_worker && nr_of_workers > min_workers ->
        Supervisor.terminate_child(WorkerPoolSupervisor, :"printer#{nr_of_workers}")
        Supervisor.delete_child(WorkerPoolSupervisor, :"printer#{nr_of_workers}")
        IO.puts("\e[031mWorkerManager: printer#{nr_of_workers} was deleted.\e[0m")

      true ->
        nil
    end

    Process.send_after(self(), :check, delay)
    {:noreply, {delay, min_workers, max_workers, task_per_worker}}
  end
end

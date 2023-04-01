defmodule Batcher do
  def start_link(batch_size, timeout, min_time) do
    IO.puts("#{__MODULE__} is going to start...")
    pid = spawn_link(__MODULE__, :init, [batch_size, timeout, min_time])
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def init(batch_size, timeout, min_time) do
    loop([], batch_size, timeout, System.system_time(:second), min_time)
  end

  defp loop(string_list, batch_size, timeout, last_print_time, min_time) do
    string_list =
      receive do
        {:matching_set_string, string} ->
          string_list ++ [string]
      after
        100 -> string_list
      end

    {string_list, last_print_time} =
      check_batch(string_list, batch_size, timeout, last_print_time, min_time)

    loop(string_list, batch_size, timeout, last_print_time, min_time)
  end

  defp check_batch(string_list, batch_size, timeout, last_print_time, min_time) do
    string_list_length = string_list |> length()
    system_time = System.system_time(:second)

    cond do
      string_list_length >= batch_size ->
        string_list |> Enum.map(&IO.puts(&1))

        IO.puts(
          "---------------- Batch Size Quota Has Been Met #{string_list_length}/#{batch_size} ----------------\n" <>
            "---------------- Last Print Time: #{last_print_time} System Time: #{system_time} ----------------\n"
        )

        time_elapsed = system_time - last_print_time
        if time_elapsed <= min_time do
          :ok = Reducer.stop()
          timeout = min_time - time_elapsed
          IO.puts("---------------- Batcher Quota Has Been Met in #{time_elapsed} seconds. Reducer stream paused for #{timeout} seconds. ----------------\n")
          Process.sleep(timeout * 1_000)
          :ok = Reducer.start()
        end

        {[], system_time}

      system_time >= last_print_time + timeout ->
        string_list |> Enum.map(&IO.puts(&1))

        IO.puts(
          "---------------- Timeout Reached #{string_list_length}/#{batch_size} ----------------\n" <>
            "---------------- Last Print Time: #{last_print_time} System Time: #{system_time} ----------------\n"
        )

        {[], system_time}

      true ->
        {string_list, last_print_time}
    end
  end
end

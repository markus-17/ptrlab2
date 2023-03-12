defmodule HashtagPrinter do
  use GenServer

  def start_link(:ok) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    {
      :ok,
      %{
        last_print_time: System.system_time(:second),
        hashtags: []
      }
    }
  end

  @impl true
  def handle_info(json, %{last_print_time: last_print_time, hashtags: hashtags}) do
    system_time = System.system_time(:second)
    new_window? = system_time - last_print_time >= 5

    hashtags =
      hashtags ++
        (json["message"]["tweet"]["entities"]["hashtags"]
         |> Enum.map(fn %{"text" => text} -> text end))

    {
      :noreply,
      %{
        last_print_time: if(new_window?, do: system_time, else: last_print_time),
        hashtags:
          if new_window? do
            {most_common_hashtag, occurences} =
              hashtags
              |> Enum.reduce(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
              |> Enum.max_by(fn {_k, v} -> v end)

            IO.puts("#{system_time}: The most common hashtag is #{most_common_hashtag} and appears #{occurences} times\n")
            []
          else
            hashtags
          end
      }
    }
  end
end

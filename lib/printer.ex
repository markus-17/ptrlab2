defmodule Printer do
  use GenServer

  def start_link(name, sleep_min, sleep_max) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, {name, sleep_min, sleep_max}, name: name)
  end

  @impl true
  def init({name, sleep_min, sleep_max}) do
    {:ok, bad_words_json} = File.read("bad_words.json")
    {:ok, bad_words_dict} = Poison.decode(bad_words_json)
    bad_words = bad_words_dict["RECORDS"] |> Enum.map(& &1["word"])
    {:ok, {name, sleep_min, sleep_max, bad_words}}
  end

  @impl true
  def handle_info("GO KILL YOURSELF", {name, sleep_min, sleep_max}) do
    IO.puts("#{name} is going to kill itself...")
    exit(:death_by_suicide)
    {:noreply, {name, sleep_min, sleep_max}}
  end

  @impl true
  def handle_info({json, msg_ref}, {name, sleep_min, sleep_max, bad_words}) do
    sleep_min..sleep_max |> Enum.random() |> Process.sleep()
    text = json["message"]["tweet"]["text"] |> String.replace("\n", " ") |> String.slice(0, 80)
    words = text |> String.split(" ", trim: True)

    formatted_words =
      words
      |> Enum.map(fn word ->
        downcased_word = word |> String.downcase()

        case Enum.find(bad_words, &(&1 == downcased_word)) do
          nil ->
            word

          _ ->
            String.duplicate("*", String.length(word))
        end
      end)

    formatted_text = formatted_words |> Enum.join(" ")

    case WorkerSpeculator.check_msg_ref(msg_ref) do
      :ok ->
        IO.puts("#{name}: #{formatted_text}")

      :late ->
        IO.puts("#{name}: Message #{inspect(msg_ref)} already printed")
    end

    {:noreply, {name, sleep_min, sleep_max, bad_words}}
  end
end

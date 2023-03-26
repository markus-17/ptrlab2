defmodule Formatter do
  use GenServer

  def start_link(name) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, {name}, name: name)
  end

  @impl true
  def init({name}) do
    bad_words = get_bad_words()
    {:ok, {name, bad_words}}
  end

  @impl true
  def handle_info({json, ref}, {name, bad_words}) do
    formatted_text = format_text(json, bad_words)
    send(Reducer, {:formatted_text, ref, name, formatted_text})
    {:noreply, {name, bad_words}}
  end

  defp get_bad_words() do
    {:ok, bad_words_json} = File.read("bad_words.json")
    {:ok, bad_words_dict} = Poison.decode(bad_words_json)
    bad_words = bad_words_dict["RECORDS"] |> Enum.map(& &1["word"])
    bad_words
  end

  defp format_text(json, bad_words) do
    text = json["message"]["tweet"]["text"] |> String.replace("\n", " ")
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

    formatted_text = formatted_words |> Enum.join(" ") |> String.slice(0, 80)
    formatted_text
  end
end

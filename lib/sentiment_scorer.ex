defmodule SentimentScorer do
  use GenServer

  def start_link(name) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, {name}, name: name)
  end

  @impl true
  def init({name}) do
    word_score_map = get_word_score_map()
    {:ok, {name, word_score_map}}
  end

  @impl true
  def handle_info({json, ref}, {name, word_score_map}) do
    sentiment_score = get_sentiment_score(json, word_score_map)
    send(Reducer, {:sentiment_score, ref, name, sentiment_score})
    {:noreply, {name, word_score_map}}
  end

  defp get_word_score_map() do
    url = "localhost:4000/emotion_values"
    %{body: response} = HTTPoison.get!(url)

    word_score_map =
      response
      |> String.split("\r\n")
      |> Enum.map(&String.split(&1, "\t"))
      |> Enum.reduce(%{}, fn [key, value], map ->
        {value, ""} = Integer.parse(value)
        Map.put(map, key, value)
      end)

    word_score_map
  end

  defp get_sentiment_score(json, word_score_map) do
    text = json["message"]["tweet"]["text"] |> String.replace("\n", " ")
    words = text |> String.split(" ", trim: True)
    sum = words |> Enum.reduce(0, fn word, acc -> acc + Map.get(word_score_map, word, 0) end)
    score = sum / length(words)
    score
  end
end

defmodule Printer do
  use GenServer

  def start_link(name) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, {name}, name: name)
  end

  @impl true
  def init({name}) do
    bad_words = get_bad_words()
    word_score_map = get_word_score_map()
    {:ok, {name, bad_words, word_score_map}}
  end

  @impl true
  def handle_info(json, {name, bad_words, word_score_map}) do
    formatted_text = format_text(json, bad_words)
    sentiment_score = get_sentiment_score(json, word_score_map)
    engagement_ratio = get_engagement_ratio(json)

    IO.puts(
      "#{name}: #{formatted_text}, Sentiment Score: #{sentiment_score}, Engagement Ratio: #{engagement_ratio}"
    )

    {:noreply, {name, bad_words, word_score_map}}
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

  defp get_engagement_ratio(json) do
    favorite_count = json["message"]["tweet"]["retweeted_status"]["favorite_count"] || 0
    retweet_count = json["message"]["tweet"]["retweeted_status"]["retweet_count"] || 0
    followers_count = json["message"]["tweet"]["user"]["followers_count"]

    engagement_ratio =
      if followers_count == 0,
        do: 0,
        else: (favorite_count + retweet_count) / followers_count

    engagement_ratio
  end
end

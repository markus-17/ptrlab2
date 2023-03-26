defmodule Reducer do
  use GenServer

  def start_link(name) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @impl true
  def init(:ok) do
    {:ok, {%{}}}
  end

  @impl true
  def handle_info({:formatted_text, ref, name, text}, {tweet_map}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :formatted_text, {name, text})

    tweet_map =
      if check_and_print(value),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map}}
  end

  @impl true
  def handle_info({:sentiment_score, ref, name, score}, {tweet_map}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :sentiment_score, {name, score})

    tweet_map =
      if check_and_print(value),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map}}
  end

  @impl true
  def handle_info({:engagement_ratio_score, ref, name, score}, {tweet_map}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :engagement_ratio_score, {name, score})

    tweet_map =
      if check_and_print(value),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map}}
  end

  defp check_and_print(map) do
    if map |> Map.keys() |> length() == 3 do
      {formatter, text} = map.formatted_text
      {sentiment_scorer, sentiment_score} = map.sentiment_score
      {engagement_ratio_scorer, engagement_ratio_score} = map.engagement_ratio_score

      IO.puts(
        "#{formatter}: #{text}\n" <>
          "#{sentiment_scorer}: #{sentiment_score}\n" <>
          "#{engagement_ratio_scorer}: #{engagement_ratio_score}\n"
      )

      true
    else
      false
    end
  end
end

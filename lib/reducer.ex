defmodule Reducer do
  use GenServer

  def start_link(name) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @impl true
  def init(:ok) do
    {:ok, {%{}, %{}, true}}
  end

  @impl true
  def handle_info({:formatted_text, ref, name, text}, {tweet_map, user_map, should_flood}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :formatted_text, {name, text})

    tweet_map =
      if check_and_print(value, user_map, should_flood),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map, user_map, should_flood}}
  end

  @impl true
  def handle_info({:sentiment_score, ref, name, score}, {tweet_map, user_map, should_flood}) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :sentiment_score, {name, score})

    tweet_map =
      if check_and_print(value, user_map, should_flood),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map, user_map, should_flood}}
  end

  @impl true
  def handle_info(
        {:engagement_ratio_score, ref, name, score, user_id},
        {tweet_map, user_map, should_flood}
      ) do
    value = Map.get(tweet_map, ref, %{})
    value = Map.put(value, :engagement_ratio_score, {name, score, user_id})

    user_map = Map.update(user_map, user_id, score, &(&1 + score))

    tweet_map =
      if check_and_print(value, user_map, should_flood),
        do: Map.delete(tweet_map, ref),
        else: Map.put(tweet_map, ref, value)

    {:noreply, {tweet_map, user_map, should_flood}}
  end

  defp check_and_print(map, user_map, should_flood) do
    if map |> Map.keys() |> length() == 3 do
      {formatter, text} = map.formatted_text
      {sentiment_scorer, sentiment_score} = map.sentiment_score
      {engagement_ratio_scorer, engagement_ratio_score, user_id} = map.engagement_ratio_score

      if should_flood do
        string =
          "#{formatter}: #{text}\n" <>
            "#{sentiment_scorer}: #{sentiment_score}\n" <>
            "#{engagement_ratio_scorer}: #{engagement_ratio_score}\n" <>
            "User with id #{user_id} has a cumulative engagement_ratio_score: #{Map.get(user_map, user_id)}\n"

        send(Batcher, {:matching_set_string, string})
      end

      true
    else
      false
    end
  end

  @impl true
  def handle_call(:start, _from, {tweet_map, user_map, _should_flood}) do
    {:reply, :ok, {tweet_map, user_map, true}}
  end

  @impl true
  def handle_call(:stop, _from, {tweet_map, user_map, _should_flood}) do
    {:reply, :ok, {tweet_map, user_map, false}}
  end

  def start do
    GenServer.call(__MODULE__, :start)
  end

  def stop do
    GenServer.call(__MODULE__, :stop)
  end
end

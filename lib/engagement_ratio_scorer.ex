defmodule EngagementRatioScorer do
  use GenServer

  def start_link(name) do
    IO.puts("#{name} is going to start...")
    GenServer.start_link(__MODULE__, {name}, name: name)
  end

  @impl true
  def init({name}) do
    {:ok, {name}}
  end

  @impl true
  def handle_info({json, ref}, {name}) do
    user_id = json["message"]["tweet"]["user"]["id"]
    engagement_ratio = get_engagement_ratio(json)
    send(Reducer, {:engagement_ratio_score, ref, name, engagement_ratio, user_id})
    {:noreply, {name}}
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

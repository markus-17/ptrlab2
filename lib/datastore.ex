defmodule Datastore do
  use GenServer

  def start_link(:ok) do
    IO.puts("#{__MODULE__} is going to start...")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    :users = :ets.new(:users, [:set, :protected, :named_table])
    :tweets = :ets.new(:tweets, [:set, :protected, :named_table])
    {:ok, nil}
  end

  @impl true
  def handle_call({:handle_batch, batch}, _from, nil) do
    new_users = batch |> Enum.map(fn %{user_id: business_key} -> business_key end)
    existing_users = :ets.tab2list(:users)

    new_users =
      new_users
      |> Enum.filter(fn business_key1 ->
        nil ==
          Enum.find(existing_users, fn {_surrogate_key, business_key2} ->
            business_key1 == business_key2
          end)
      end)

    new_surrogate_key = length(existing_users) + 1
    surrogate_keys = new_surrogate_key..(new_surrogate_key + length(new_users))
    new_users = Enum.zip(surrogate_keys, new_users)
    :ets.insert(:users, new_users)

    all_users = existing_users ++ new_users

    tweets =
      batch
      |> Enum.map(fn %{
                       user_id: user_id,
                       text: text,
                       sentiment_score: sentiment_score,
                       engagement_ratio_score: engagement_ratio_score
                     } ->
        [
          Enum.find(all_users, fn {_, business_key} -> business_key == user_id end) |> elem(0),
          text,
          sentiment_score,
          engagement_ratio_score
        ]
      end)

    new_tweet_key = (:ets.tab2list(:tweets) |> length()) + 1
    tweet_keys = new_tweet_key..new_tweet_key + length(tweets)

    tweets = Enum.zip_with([tweet_keys, tweets], fn [key, [a, b, c, d]] -> {key, a, b, c, d} end)
    :ets.insert(:tweets, tweets)

    {:reply, :ok, nil}
  end

  @impl true
  def handle_call({:get_all_users}, _from, nil) do
    {:reply, :ets.tab2list(:users), nil}
  end

  @impl true
  def handle_call({:get_all_tweets}, _from, nil) do
    {:reply, :ets.tab2list(:tweets), nil}
  end

  def insert_batch(batch) do
    GenServer.call(__MODULE__, {:handle_batch, batch})
  end

  def get_all_users() do
    GenServer.call(__MODULE__, {:get_all_users})
  end

  def get_all_tweets() do
    GenServer.call(__MODULE__, {:get_all_tweets})
  end
end

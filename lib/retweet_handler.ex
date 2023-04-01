defmodule RetweetHandler do
  use GenServer

  def start_link(:ok) do
    IO.puts("#{__MODULE__} is going to start...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    {:ok, nil}
  end

  @impl true
  def handle_info({:check_for_retweet, message}, nil) do
    retweet = message["message"]["tweet"]["retweeted_status"]
    if retweet != nil do
      retweet_message = %{
        "message" => %{
          "tweet" => retweet
        }
      }
      send(LoadBalancer, retweet_message)
    end
    {:noreply, nil}
  end
end

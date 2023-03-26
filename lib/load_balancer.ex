defmodule LoadBalancer do
  use GenServer

  def start_link(:ok) do
    IO.puts("LoadBalancer is going to start...")
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    {:ok, nil}
  end

  @impl true
  def handle_info("GO KILL YOURSELF", state) do
    # printer_name = :"printer#{Enum.random(1..nr_of_printers)}"
    # if Process.whereis(printer_name) != nil, do: send(printer_name, "GO KILL YOURSELF")
    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    hash_distribution_key = message["message"]["tweet"]["text"]
    last_byte = :crypto.hash(:sha256, hash_distribution_key) |> :binary.last()

    [nr_of_formatters, nr_of_sentiment_scorers, nr_of_engagement_ratio_scorers] =
      [FormatterWorkerPool, SentimentScorerWorkerPool, EngagementRatioScorerWorkerPool]
      |> Enum.map(&Supervisor.count_children(&1).specs)

    [formatter, sentiment_scorer, engagement_ratio_scorer] =
      [
        {"formatter", nr_of_formatters},
        {"sentiment_scorer", nr_of_sentiment_scorers},
        {"engagement_ratio_scorer", nr_of_engagement_ratio_scorers}
      ]
      |> Enum.map(fn {name, i} ->
        :"#{name}#{(last_byte |> rem(i)) + 1}"
      end)

    ref = make_ref()
    [formatter, sentiment_scorer, engagement_ratio_scorer] |> Enum.map(&send(&1, {message, ref}))
    {:noreply, state}
  end
end

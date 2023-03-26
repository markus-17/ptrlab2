defmodule WorkerPoolSupervisor do
  use Supervisor

  def start_link({type, number}) do
    children = get_children(type, number)
    name = get_name(type)
    Supervisor.start_link(__MODULE__, children, name: name)
  end

  @impl true
  def init(children) do
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp get_children(type, number) do
    {name, module} =
      case type do
        :formatter -> {"formatter", Formatter}
        :sentiment_scorer -> {"sentiment_scorer", SentimentScorer}
        :engagement_ratio_scorer -> {"engagement_ratio_scorer", EngagementRatioScorer}
      end

    1..number
    |> Enum.map(fn n ->
      %{
        id: :"#{name}#{n}",
        start: {module, :start_link, [:"#{name}#{n}"]}
      }
    end)
  end

  defp get_name(type) do
    case type do
      :formatter -> FormatterWorkerPool
      :sentiment_scorer -> SentimentScorerWorkerPool
      :engagement_ratio_scorer -> EngagementRatioScorerWorkerPool
    end
  end

  def get_specification(type, number) do
    id = get_name(type)
    %{
      id: id,
      start: {WorkerPoolSupervisor, :start_link, [{type, number}]}
    }
  end
end

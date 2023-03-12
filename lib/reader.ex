defmodule Reader do
  use GenServer

  def start_link({name, url}) do
    GenServer.start_link(__MODULE__, url, name: name)
  end

  @impl true
  def init(url) do
    HTTPoison.get!(url, [], recv_timeout: :infinity, stream_to: self())
    {:ok, nil}
  end

  @impl true
  def handle_info(%HTTPoison.AsyncChunk{chunk: data}, state) do
    [_, json] = Regex.run(~r/data: ({.+})\n\n$/, data)

    case json |> Poison.decode() do
      {:ok, result} ->
        send(Printer, result)

      {:error, _} ->
        nil
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(_, state) do
    {:noreply, state}
  end
end

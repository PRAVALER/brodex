defmodule Brodex.ProducerServer do
  @moduledoc false

  use GenServer

  alias Brodex.Config

  require Logger

  def start_link([topic, partition]) do
    name = "producer_#{topic}"
      |> String.replace("-", "_")
      |> String.to_atom()

    GenServer.start_link(__MODULE__, [topic, partition], name: name)
  end

  @impl true
  def init([topic, partition]) do
    {:ok, _pid} = :brod_producer.start_link(Config.get_client_id(), topic, partition, _producer_config = [])
    {:ok, [topic, partition]}
  end
end

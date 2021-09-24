defmodule Brodex.ConsumersSupervisor do
  use Supervisor

  alias Brodex.Config

  require Logger

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children =
      Config.get_kafka_topics()
      |> Enum.map(fn topic_config -> %{id: topic_config.name, start: {Brodex.TopicSupervisor, :start_link, [[topic_config]]}} end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end

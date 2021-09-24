defmodule Brodex.TopicSupervisor do
  use Supervisor

  require Logger

  def start_link([topic_config]) do
    Supervisor.start_link(__MODULE__, topic_config, name: topic_config.name)
  end

  @impl true
  def init(topic_config) do
    children = [
      %{id: topic_config.topic, start: {Brodex.ConsumerServer, :start_link, [[topic_config]]}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

defmodule Brodex.Supervisor do
  use Supervisor

  require Logger

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Logger.info("kafka supervisor init")

    children = [
      {Brodex.ParentConsumersSupervisor, []},
      {Brodex.ProducerSupervisor, []},
      {Brodex.Client, []}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end

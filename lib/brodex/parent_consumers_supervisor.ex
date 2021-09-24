defmodule Brodex.ParentConsumersSupervisor do
  @moduledoc false

  use DynamicSupervisor

  require Logger

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      name: Brodex.ParentConsumersSupervisor
    )
  end

  def start_consumers do
    restart_consumers()

    DynamicSupervisor.start_child(
      Brodex.ParentConsumersSupervisor,
      %{id: Brodex.ConsumersSupervisor, start: {Brodex.ConsumersSupervisor, :start_link, [[]]}}
    )
  end

  def restart_consumers do
    which_children = DynamicSupervisor.which_children(Brodex.ParentConsumersSupervisor)
    case which_children do
      [{:undefined, pid, :worker, [_module]}] -> Process.exit(pid, :kill)
      _ -> {:ok, false}
    end
  end
end
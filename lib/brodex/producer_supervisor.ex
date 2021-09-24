defmodule Brodex.ProducerSupervisor do
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
      name: Brodex.ProducerSupervisor
    )
  end

  def start_message_sender do
    DynamicSupervisor.start_child(
      Brodex.ProducerSupervisor,
      %{id:  Brodex.MessageSender, start: {Brodex.MessageSender, :start_link, [[]]}}
    )
  end

  def start_producer(topic, partition) do
    DynamicSupervisor.start_child(
      Brodex.ProducerSupervisor,
      %{id: "producer_#{topic}", start: {Brodex.ProducerServer, :start_link, [[topic, partition]]}}
    )
  end
end
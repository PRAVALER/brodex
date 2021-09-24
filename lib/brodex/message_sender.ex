defmodule Brodex.MessageSender do
  @moduledoc false

  use GenServer

  alias Brodex.Config
  alias Brodex.ProducerSupervisor

  require Logger

  @spec send_message(String.t(), non_neg_integer(), map(), non_neg_integer()) :: :ok | {:error, any()}
  def send_message(topic, partition, data, 0) do
    send_message_sync(topic, partition, data)
  end

  @spec send_message(String.t(), non_neg_integer(), map(), non_neg_integer()) :: :ok | {:error, any()}
  def send_message(topic, partition, data, seconds) do
    send_message_async(topic, partition, data, seconds)
  end

  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, [], name: Brodex.MessageSender)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_info({:send_message, topic, partition, data}, state) do
    send_message_sync(topic, partition, data)
    {:noreply, state}
  end

  @spec send_message_async(String.t(), non_neg_integer(), map(), non_neg_integer()) :: :ok | {:error, any()}
  defp send_message_async(topic, partition, data, seconds) do
    Process.send_after(Brodex.MessageSender, {:send_message, topic, partition, data}, seconds * 1_000)
  end

  @spec send_message_sync(String.t(), non_neg_integer(), map()) :: :ok | {:error, any()}
  defp send_message_sync(topic, partition, data) do
    result = :brod.produce_sync(Config.get_client_id(), topic, partition, _key = "", Poison.encode!(data))
    case result do
      {:error, {:producer_not_found, _topic_name}} -> retry_send_message(topic, partition, data)
      _ -> result
    end
  end

  @spec retry_send_message(String.t(), non_neg_integer(), map()) :: :ok | {:error, any()}
  defp retry_send_message(topic, partition, data) do
    Logger.info("creating producer for topic: #{topic}")

    ProducerSupervisor.start_producer(topic, partition)
    :brod.produce_sync(Config.get_client_id(), topic, partition, _key = "", Poison.encode!(data))
  end
end

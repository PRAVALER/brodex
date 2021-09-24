defmodule Brodex.Client do
  @moduledoc false

  use GenServer

  alias Brodex.Config
  alias Brodex.ParentConsumersSupervisor
  alias Brodex.ProducerSupervisor

  require Logger

  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, false, name: __MODULE__)
  end

  @impl true
  def init(connected) do
    kafka_connect()
    {:ok, connected}
  end

  @impl true
  def handle_info(:work, connected) do
    [{host, port}] = Config.get_hosts()
    connection = :brod_client.get_connection(Config.get_client_id(), host, port)
    case connection do
      {:ok, _pid} -> kafka_connect_work(connected)
      _ -> kafka_connect_retry(connected)
    end
  end

  defp kafka_connect_work(connected) do
    if (connected == false) do
      Logger.info("kafka connected")
      ParentConsumersSupervisor.start_consumers()
      ProducerSupervisor.start_message_sender()
    end

    Process.send_after(self(), :work, 5 * 1_000)
    {:noreply, true}
  end

  defp kafka_connect_retry(_connected) do
    Logger.info("kafka connecting...")

    :brod_client.start_link(Config.get_hosts(), Config.get_client_id(), _client_config = Config.get_client_config())
    Process.send_after(self(), :work, 1 * 1_000)
    {:noreply, false}
  end

  defp kafka_connect do
    Process.send_after(self(), :work, 500)
  end
end

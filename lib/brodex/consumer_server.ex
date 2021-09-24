defmodule Brodex.ConsumerServer do
  @moduledoc false

  alias Brodex.Config
  alias Brodex.Message

  require Logger

  @behaviour :brod_group_subscriber_v2

  def start_link([topic_config]) do
    topics = Config.get_topic_names(topic_config)

    group_config = [
      offset_commit_policy: :commit_to_kafka_v2,
      offset_commit_interval_seconds: 5,
      rejoin_delay_seconds: 2,
      reconnect_cool_down_seconds: 10
    ]

    config = %{
      client: Config.get_client_id(),
      group_id: Config.get_consumer_group(),
      topics: topics,
      cb_module: __MODULE__,
      group_config: group_config,
      consumer_config: [begin_offset: :earliest]
    }

    :brod.start_link_group_subscriber_v2(config)
  end

  @impl :brod_group_subscriber_v2
  def init(_arg, _arg2) do
    {:ok, []}
  end

  @impl :brod_group_subscriber_v2
  def handle_message(content, _state) do
    {:kafka_message_set, topic, partition, _offset, messages} = content

    for {:kafka_message, _offset, _key, message_data, _type, _time, _opt} <- messages do
      kafka_message = Message.factory!(topic, message_data)
      process_message(kafka_message, partition)
    end

    {:ok, :commit, []}
  end

  @spec process_message(Message.t(), non_neg_integer()) :: {:ok, any()} | {:error, any()}
  defp process_message(kafka_message, partition) do
    module = Config.get_module_by_topic(kafka_message.topic)
    module.process_message(kafka_message, partition)
  end
end

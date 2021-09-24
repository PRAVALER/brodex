defmodule Brodex.Config do

  defp get_config(config),
       do: Application.get_env(:brodex, :kafka)[config]

  def get_kafka_topics,
       do: Application.fetch_env!(:brodex, :kafka_topics)

  def get_hosts, do: get_config(:hosts)
  def get_topic_prefix, do: get_config(:topic_prefix)
  def get_client_id, do: get_config(:client_id)
  def get_use_ssl, do: get_config(:use_ssl)
  def get_sasl, do: get_config(:sasl)
  def get_consumer_group, do: get_config(:consumer_group)
  def get_max_retry, do: get_config(:max_retry)
  def get_retry_suffix, do: get_config(:retry_suffix)
  def get_dlq_suffix, do: get_config(:dlq_suffix)

  def get_client_config do
    case get_config(:sasl) do
      nil -> [client_id: get_client_id(), ssl: get_config(:use_ssl)]
      _ -> [client_id: get_client_id(), ssl: get_config(:use_ssl), sasl: get_config(:sasl)]
    end
  end

  @spec get_module_by_topic(String.t()) :: module()
  def get_module_by_topic(topic) do
    get_kafka_topics()
    |> Enum.find(fn topic_config -> topic_config.topic == topic end)
    |> Map.get(:module)
  end

  @spec get_topic_names() :: list(String.t())
  def get_topic_names do
    get_kafka_topics()
    |> Enum.map(fn topic_config -> topic_config.topic end)
    |> add_retry_topics()
  end

  @spec get_topic_names(map()) :: list(String.t())
  def get_topic_names(topic_config) do
    [topic_config]
    |> Enum.map(fn topic_config -> topic_config.topic end)
    |> add_retry_topics()
  end

  @spec add_retry_topics(list(String.t())) :: list(String.t())
  defp add_retry_topics(topics) do
    topics
    |> Enum.map(&add_retry_topic_suffix/1)
    |> Enum.flat_map(fn topic -> topic end)
  end

  @spec add_retry_topic_suffix(String.t()) :: list(String.t())
  defp add_retry_topic_suffix(topic) do
    topics_retry =
      0..(get_max_retry() - 1)
      |> Enum.map(fn i -> "#{topic}_#{get_retry_suffix()}_#{i}" end)

    Enum.concat([topic], topics_retry)
  end
end

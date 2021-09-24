defmodule Brodex.Consumer do
  @moduledoc false

  @callback handler(Map.t()) :: any

  defmacro __using__(_opts) do
    quote do
      alias Brodex.Config
      alias Brodex.MessageSender

      @behaviour Brodex.Consumer

      @spec process_message(Message.t(), non_neg_integer()) :: {:ok, any()} | {:error, any()}
      def process_message(kafka_message, partition) do
        {:ok, _} = handler(kafka_message.data)
      rescue
        _ -> retry_message(kafka_message, partition)
      end

      @spec retry_message(Message.t(), non_neg_integer()) :: {:ok, true} | {:error, any()}
      defp retry_message(kafka_message, partition) do
        if kafka_message.retry < Config.get_max_retry(),
           do: send_retry_message(kafka_message, partition),
           else: send_dlq_message(kafka_message, partition)
      end

      @spec send_retry_message(Message.t(), non_neg_integer()) :: {:ok, true} | {:error, any()}
      defp send_retry_message(kafka_message, partition) do
        topic_name = "#{kafka_message.topic}_#{Config.get_retry_suffix()}_#{kafka_message.retry}"
        MessageSender.send_message(topic_name, partition, kafka_message, 5)

        {:ok, true}
      end

      @spec send_dlq_message(Message.t(), non_neg_integer()) :: {:ok, true} | {:error, any()}
      defp send_dlq_message(kafka_message, partition) do
        topic_name = "#{kafka_message.topic}_#{Config.get_dlq_suffix()}"
        :ok = MessageSender.send_message(topic_name, partition, kafka_message.data, 0)

        {:ok, true}
      end
    end
  end
end

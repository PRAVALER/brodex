defmodule Brodex.Message do
  alias Brodex.Message

  require Logger

  use TypedStruct
  @derive[Poison.Encoder]

  typedstruct do
    field :retry, non_neg_integer(), default: 0
    field :topic, String.t()
    field :data, Map.t(), default: %{}
  end

  @spec get_json(Message.t()) :: iodata | no_return
  def get_json(message) do
    message |> Poison.encode!()
  end

  @spec factory!(String.t(), any()) :: Message.t() | nil
  def factory!(topic, message) do
    factory_kafka_message(topic, Jason.decode(message))
  end

  defp factory_kafka_message(topic, {:error, %Jason.DecodeError{data: data} = _message}) do
    %Message{retry: 0, topic: topic, data: data}
  end

  defp factory_kafka_message(_retry_topic, {:ok, %{"topic" => topic, "retry" => retry, "data" => data} = _message_decode}) do
    %Message{retry: retry + 1, topic: topic, data: data}
  end

  defp factory_kafka_message(topic, {:ok, data}) do
    %Message{retry: 0, topic: topic, data: data}
  end
end

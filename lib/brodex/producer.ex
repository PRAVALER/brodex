defmodule Brodex.Producer do
  @moduledoc false
  alias Brodex.MessageSender

  require Logger

  @spec produce(String.t(), non_neg_integer(), map(), non_neg_integer()) :: :ok | {:error, any()}
  def produce(topic, partition, data, seconds \\ 0) do
    MessageSender.send_message(topic, partition, data, seconds)
  end
end

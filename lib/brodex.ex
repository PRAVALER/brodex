defmodule Brodex do

  alias Brodex.Producer

  require Logger

  @moduledoc """
  Documentation for `Brodex`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Brodex.hello()
      :world

  """
  @spec hello() :: :world
  def hello do
    :world
  end

  @spec produce(String.t(), non_neg_integer(), map(), non_neg_integer()) :: :ok | {:error, any()}
  def produce(topic, partition, data, seconds \\ 0) do
    Producer.produce(topic, partition, data, seconds)
  end
end

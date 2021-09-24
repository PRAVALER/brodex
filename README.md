# Brodex

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `brodex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:brodex, git: "https://github.com/PRAVALER/brodex"}
  ]
end
```

## Configuration

See [config/config.exs](https://github.com/PRAVALER/brodex/blob/main/config/config.exs)
for a description of configuration variables, including the Kafka broker list
and default consumer group.

### Consumer Configs

```elixir
import Config

alias BrodexExampleWeb.ConsumerTest

config :brodex,
    kafka_topics: [
      %{name: :topic_test, topic: "topic-test", partitions: :all, module: ConsumerTest}
    ]
```

## Usage Examples

### Consumer Groups

To use a consumer group, first implement a handler module using
`Brodex.Consumer`.

```elixir
defmodule BrodexExampleWeb.ConsumerTest do

  use Brodex.Consumer

  @impl true
  def handler(data) do
    IO.inspect(data, label: "data")
    {:ok, true}
  end
end
```


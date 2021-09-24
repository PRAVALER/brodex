use Mix.Config

config :brodex,
  kafka: [
    # A list of brokers to connect to. This can be in either of the following formats
    #
    #  * [{"HOST", port}...]
    #  * CSV - `"HOST:PORT,HOST:PORT[,...]"`
    #  * {mod, fun, args}
    #  * &arity_zero_fun/0
    #  * fn -> ... end
    #
   hosts: [{"kafka", 29092}],

   # the default consumer group for worker processes, must be a binary (string)
   consumer_group: "brodex_example_consumer_group",

   # The client_id is the logical grouping of a set of kafka clients, must be a atom.
   client_id: :brodex_example_client_id,

   # This is the flag that enables use of ssl
   use_ssl: false,

   # Credentials for SASL/Plain authentication.
   # `{mechanism(), Filename}' or `{mechanism(), UserName, Password}'
   # where mechanism can be atoms: `plain' (for "PLAIN"), `scram_sha_256'
   # (for "SCRAM-SHA-256") or `scram_sha_512' (for SCRAM-SHA-512).
   # `Filename' should be a file consisting two lines, first line
   # is the username and the second line is the password.
   # Both `Username' and `Password' should be `string() | binary()'</li>
   sasl: nil,

   # the default published topic prefix must be a binary (string). Example where the prefix is brodex the publication in the test-topic would be done in the brodex-topic-test topic
   topic_prefix: "brodex",

   max_retry: 5,
   retry_suffix: "retry",
   dlq_suffix: "dlq"
  ]
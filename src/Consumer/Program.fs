open System
open Confluent.Kafka

[<EntryPoint>]
let main argv =
    let config = ConsumerConfig(
                    GroupId = "test-consumer-group",
                    BootstrapServers = "localhost:9092",
                    AutoOffsetReset = Nullable AutoOffsetReset.Earliest)

    let consumer = ConsumerBuilder<Ignore, string>(config).Build()
    consumer.Subscribe("test")

    while true do
        let received = consumer.Consume()
        printfn "Consumed message %A at: %A." received.Value received.TopicPartitionOffset

    0 // return an integer exit code

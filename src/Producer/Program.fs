open System
open System.Threading.Tasks
open Confluent.Kafka

let AwaitTaskVoid: Task -> Async<unit> = Async.AwaitIAsyncResult >> Async.Ignore

[<EntryPoint>]
let main argv =
    let config = ProducerConfig(BootstrapServers = "localhost:9092")

    let topic = "test"
    let producer = ProducerBuilder(config).Build()

    let mutable iteration = 0

    let loop() = async {
        while true do
            iteration <- iteration + 1

            let text = sprintf "Hello World from F#! %A" iteration
            let message = new Message<string, string>(Key = "hello", Value = text)

            printfn "Sending %A" text
            do! producer.ProduceAsync(topic, message) |> AwaitTaskVoid
            do! Task.Delay(5000) |> Async.AwaitTask
        }

    loop() |> Async.RunSynchronously

    0 // return an integer exit code

# Scala Stream Collector - compiling from source

### change into scala-stream-collector directory
```sh
$ cd 2-collectors/scala-stream-collector
```

### create jar for kinesis
```sh
scala-stream-collector$ sbt "project kinesis" assembly
```

### generated jar will be in kinesis/target/scala-2.11
```sh
scala-stream-collector$ ls kinesis/target/scala-2.11/snowplow-stream-collector-stdout-0.15.0.jar
kinesis/target/scala-2.11/snowplow-stream-collector-stdout-0.15.0.jar
```


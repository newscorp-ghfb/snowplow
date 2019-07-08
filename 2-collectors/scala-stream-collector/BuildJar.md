# Scala Stream Collector - compiling from source

### change into scala-stream-collector directory
$ cd 2-collectors/scala-stream-collector

### generate jar for kinesis
sbt "project kinesis" assembly

### generated jar will be in *kinesis/target/scala-2.11/snowplow-stream-collector-stdout-0.15.0.jar*


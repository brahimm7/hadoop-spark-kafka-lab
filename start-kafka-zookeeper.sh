#!/bin/bash
echo "Launching ZooKeeper..."
$KAFKA_HOME/bin/zookeeper-server-start.sh -daemon $KAFKA_HOME/config/zookeeper.properties
sleep 3

echo "Launching the Kafka Broker..."
$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties
echo "✓ ZooKeeper and Kafka started in the background!"
#!/bin/bash

# Run Stream Consumer in Docker Spark container
docker exec -it food_delivery_spark_master spark-submit \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.1 \
  --master spark://spark-master:7077 \
  /opt/spark-apps/consumers/orders_stream_consumer.py \
  --config /opt/spark-apps/configs/orders_stream.yml

#!/bin/bash

# Run CDC Producer in Docker Spark container
echo "Creating Ivy cache directory..."
docker exec -u root food_delivery_spark_master mkdir -p /opt/spark/.ivy2/cache
docker exec -u root food_delivery_spark_master chmod -R 777 /opt/spark/.ivy2

echo "Starting CDC Producer..."
docker exec -it food_delivery_spark_master /opt/spark/bin/spark-submit \
  --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.1,org.postgresql:postgresql:42.6.0 \
  --master spark://spark-master:7077 \
  /opt/spark-apps/producers/orders_cdc_producer.py \
  --config /opt/spark-apps/configs/orders_stream.yml

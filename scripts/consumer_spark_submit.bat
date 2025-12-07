@echo off
REM Run Stream Consumer in Docker Spark container (Windows)

echo Installing dependencies...
docker exec -u root food_delivery_spark_master pip install pyyaml

echo Creating Ivy cache directory...
docker exec -u root food_delivery_spark_master mkdir -p /opt/spark/.ivy2/cache
docker exec -u root food_delivery_spark_master chmod -R 777 /opt/spark/.ivy2

echo Starting Stream Consumer...
docker exec -it food_delivery_spark_master /opt/spark/bin/spark-submit --packages org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.0 --master spark://spark-master:7077 --executor-memory 1G --executor-cores 1 /opt/spark-apps/consumers/orders_stream_consumer.py --config /opt/spark-apps/configs/orders_stream.yml

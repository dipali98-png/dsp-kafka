@echo off
docker exec -it food_delivery_spark_master /opt/spark/bin/spark-submit --master local[1] /opt/spark-apps/scripts/read_parquet.py

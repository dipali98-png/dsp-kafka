#!/bin/bash

echo "========================================"
echo "Pipeline Validation Script"
echo "========================================"
echo ""

echo "1. Checking PostgreSQL records..."
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) as total_records FROM ROLL001_orders;"

echo ""
echo "2. Checking Kafka topic..."
echo "(Showing first 5 messages)"
docker exec -it food_delivery_kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ROLL001_food_orders_raw --from-beginning --max-messages 5 --timeout-ms 5000

echo ""
echo "3. Checking Data Lake files..."
docker exec -it food_delivery_spark_master ls -lR /opt/spark-apps/datalake/food/ROLL001/output/orders/

echo ""
echo "4. Checking checkpoint location..."
docker exec -it food_delivery_spark_master ls -lR /opt/spark-apps/datalake/food/ROLL001/checkpoints/orders/

echo ""
echo "5. Checking last processed timestamp..."
docker exec -it food_delivery_spark_master cat /opt/spark-apps/datalake/food/ROLL001/lastprocess/orders/last_timestamp.txt

echo ""
echo "========================================"
echo "Validation Complete"
echo "========================================"

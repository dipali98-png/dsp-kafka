#!/bin/bash

echo "========================================"
echo "Food Delivery Streaming Pipeline"
echo "========================================"
echo ""

echo "Starting Docker services..."
docker-compose up -d

echo ""
echo "Waiting for services to be ready (30 seconds)..."
sleep 30

echo ""
echo "Services started successfully!"
echo ""
echo "PostgreSQL: localhost:5432"
echo "Kafka: localhost:9092"
echo "Spark Master UI: http://localhost:8080"
echo ""
echo "Verifying database..."
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) FROM ROLL001_orders;"

echo ""
echo "========================================"
echo "Next Steps:"
echo "========================================"
echo "1. Start Producer: ./scripts/producer_spark_submit.sh"
echo "2. Start Consumer: ./scripts/consumer_spark_submit.sh"
echo "3. Insert test data to see real-time processing"
echo ""
echo "To stop: docker-compose down"
echo "========================================"

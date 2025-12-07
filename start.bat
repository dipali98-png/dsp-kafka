@echo off
echo ========================================
echo Food Delivery Streaming Pipeline
echo ========================================
echo.

echo Starting Docker services...
docker-compose up -d

echo.
echo Waiting for services to be ready (30 seconds)...
timeout /t 30 /nobreak

echo.
echo Services started successfully!
echo.
echo PostgreSQL: localhost:5432
echo Kafka: localhost:9092
echo Spark Master UI: http://localhost:8080
echo.
echo Inserting initial 10 records...
scripts\insert_initial_data.bat

echo.
echo ========================================
echo Next Steps:
echo ========================================
echo 1. Start Producer: scripts\producer_spark_submit.bat
echo 2. Start Consumer: scripts\consumer_spark_submit.bat
echo 3. Insert test data: scripts\insert_test_data.bat
echo.
echo To stop: docker-compose down
echo ========================================

@echo off
echo Inserting 5 test records into PostgreSQL...
docker exec -i food_delivery_postgres psql -U student -d food_delivery_db < db\insert_test_data.sql
echo.
echo Test data inserted successfully!
echo Check the producer and consumer logs to see real-time processing.

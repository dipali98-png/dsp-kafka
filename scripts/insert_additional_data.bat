@echo off
REM Insert 5 additional records for testing incremental ingestion

echo ========================================
echo Inserting 5 Additional Records
echo ========================================
echo.

docker exec -i food_delivery_postgres psql -U student -d food_delivery_db < db\insert_additional_data.sql

echo.
echo ========================================
echo Additional data inserted successfully!
echo ========================================

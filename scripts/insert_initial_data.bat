@echo off
echo ========================================
echo Setting Up Database
echo ========================================
echo.

echo Waiting for PostgreSQL to be ready...
timeout /t 5 /nobreak > nul

echo Creating table...
docker exec -i food_delivery_postgres psql -U student -d food_delivery_db < db\orders.sql

echo Inserting initial 10 records...
docker exec -i food_delivery_postgres psql -U student -d food_delivery_db < db\insert_initial_data.sql

echo.
echo ========================================
echo Initial data inserted successfully!
echo ========================================

#!/bin/bash

echo "========================================"
echo "Inserting 10 Initial Records"
echo "========================================"
echo ""

echo "Waiting for PostgreSQL to be ready..."
sleep 5

echo "Inserting initial data..."
docker exec -i food_delivery_postgres psql -U student -d food_delivery_db < db/insert_initial_data.sql

echo ""
echo "========================================"
echo "Initial data inserted successfully!"
echo "========================================"

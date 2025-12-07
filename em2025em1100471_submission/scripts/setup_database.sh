#!/bin/bash

# Setup database: Create table and insert initial 10 records

echo "Creating table and inserting initial 10 records..."
docker exec -i food_delivery_postgres psql -U student -d food_delivery_db < db/orders.sql

echo "Database setup complete!"
echo "Verifying records..."
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) FROM em2025em1100471_orders;"

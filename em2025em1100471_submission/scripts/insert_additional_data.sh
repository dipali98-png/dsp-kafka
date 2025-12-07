#!/bin/bash

# Insert 5 additional records for testing incremental ingestion

echo "Inserting 5 additional records..."
docker exec -i food_delivery_postgres psql -U student -d food_delivery_db < db/03_insert_additional_data.sql

echo "Done! Check producer and consumer logs to see the records being processed."

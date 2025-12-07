# Food Delivery Streaming Pipeline - em2025em1100471

## Project Structure
```
em2025em1100471_submission/
├── db/
│   ├── orders.sql                      # Database schema + 10 initial records
│   └── 03_insert_additional_data.sql   # Additional 5 records
├── producers/
│   └── orders_cdc_producer.py          # CDC producer (PySpark)
├── consumers/
│   └── orders_stream_consumer.py       # Stream consumer (PySpark)
├── configs/
│   └── orders_stream.yml               # Configuration file
├── scripts/
│   ├── setup_database.sh               # Create table and insert initial 10 records
│   ├── producer_spark_submit.sh        # Producer submit script
│   ├── consumer_spark_submit.sh        # Consumer submit script
│   └── insert_additional_data.sh       # Insert 5 additional records
├── docker-compose.yml                  # Docker services
├── Dockerfile                          # Custom Spark image
└── README.md
```

## Setup and Run

### 1. Build and Start Services
```bash
docker-compose build
docker-compose up -d
```

Wait 30 seconds for services to initialize.

### 2. Setup Database (Run Once)
```bash
chmod +x scripts/setup_database.sh
./scripts/setup_database.sh
```

This creates the table and inserts 10 initial records with dynamic timestamps.

### 3. Start Producer (Terminal 1)
```bash
chmod +x scripts/producer_spark_submit.sh
./scripts/producer_spark_submit.sh
```

### 4. Start Consumer (Terminal 2)
```bash
chmod +x scripts/consumer_spark_submit.sh
./scripts/consumer_spark_submit.sh
```

### 5. Insert Additional 5 Records (Terminal 3)
```bash
chmod +x scripts/insert_additional_data.sh
./scripts/insert_additional_data.sh
```

Or manually:
```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db
```

```sql
INSERT INTO em2025em1100471_orders (customer_name, restaurant_name, item, amount, order_status) VALUES
('Tom Anderson', 'Burger Junction', 'Cheese Burger', 240.00, 'PLACED'),
('Anna Taylor', 'Pizza Palace', 'Veggie Supreme', 380.00, 'PLACED'),
('Chris Martin', 'Sushi World', 'Spicy Tuna Roll', 480.00, 'PLACED'),
('Laura White', 'Taco Bell', 'Beef Quesadilla', 220.00, 'PLACED'),
('Kevin Lee', 'Pasta House', 'Carbonara', 340.00, 'PLACED');
```

## Verification

Check data lake:
```bash
docker exec -it food_delivery_spark_master ls -la /opt/spark-apps/datalake/food/em2025em1100471/output/orders/
```

## Student: em2025em1100471

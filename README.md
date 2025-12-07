# Food Delivery Streaming Pipeline

A real-time streaming pipeline for food delivery orders using PostgreSQL, Kafka, and Spark Structured Streaming, all containerized with Docker.

## How This Project is Built

This project implements a complete end-to-end streaming data pipeline using modern big data technologies:

**Technology Stack:**
- **PostgreSQL**: Source database storing food delivery orders with automatic timestamp tracking
- **Apache Kafka**: Distributed message broker for real-time data streaming
- **Apache Spark**: Distributed processing engine for both CDC producer and stream consumer
- **Docker & Docker Compose**: Containerization for easy deployment and orchestration

**Pipeline Components:**
1. **CDC Producer** (PySpark): Polls PostgreSQL every 5 seconds to detect new records based on `created_at` timestamp and publishes them to Kafka
2. **Kafka Topic**: Acts as the streaming buffer between producer and consumer
3. **Stream Consumer** (Spark Structured Streaming): Reads from Kafka in real-time, applies data quality rules, and writes to Data Lake
4. **Data Lake**: Stores processed data in Parquet format with date-based partitioning for efficient querying

**Key Features:**
- Incremental data ingestion without duplicates
- Data quality checks (null filtering, negative amount validation)
- Fault tolerance with Spark checkpointing
- Scalable architecture using distributed systems
- Configuration-driven design for easy customization

## Architecture

```
PostgreSQL → CDC Producer (PySpark) → Kafka → Stream Consumer (PySpark) → Data Lake (Parquet)
```

## Prerequisites

- Docker Desktop installed and running
- Docker Compose
- At least 8GB RAM allocated to Docker

## Project Structure

```
DSP/
├── db/
│   └── orders.sql                      # Database schema and initial data
├── producers/
│   └── orders_cdc_producer.py          # CDC producer (polls PostgreSQL)
├── consumers/
│   └── orders_stream_consumer.py       # Stream consumer (reads from Kafka)
├── scripts/
│   ├── producer_spark_submit.sh        # Producer submit script (Linux/Mac)
│   ├── consumer_spark_submit.sh        # Consumer submit script (Linux/Mac)
│   ├── producer_spark_submit.bat       # Producer submit script (Windows)
│   └── consumer_spark_submit.bat       # Consumer submit script (Windows)
├── configs/
│   └── orders_stream.yml               # Configuration file
├── datalake/                           # Data lake storage (created at runtime)
├── docker-compose.yml                  # Docker services configuration
└── README.md
```

## Running the Project with Docker

### Step 1: Start Docker Services

Start all required services (PostgreSQL, Kafka, Zookeeper, Spark):

```bash
docker-compose up -d
```

This command starts:
- **PostgreSQL** (port 5432) - Source database with auto-initialized schema and 10 sample records
- **Zookeeper** (port 2181) - Kafka coordination service
- **Kafka** (port 9092) - Message broker
- **Spark Master** (port 8080, 7077) - Spark cluster manager
- **Spark Worker** - Spark executor node

### Step 2: Verify All Services are Running

Check service status:

```bash
docker-compose ps
```

All services should show "Up" status. Wait ~30 seconds for Kafka to fully initialize.

### Step 3: Verify Database Initialization

Confirm the database table and initial 10 records were created:

```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) FROM ROLL001_orders;"
```

Expected output: `count = 10`

### Step 4: Start the CDC Producer

The producer runs inside the Spark Master container and polls PostgreSQL for new records.

**Windows:**
```bash
scripts\producer_spark_submit.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/producer_spark_submit.sh
./scripts/producer_spark_submit.sh
```

The producer will:
- Poll PostgreSQL every 5 seconds
- Detect new records based on `created_at` timestamp
- Publish them to Kafka topic `ROLL001_food_orders_raw`
- Display logs showing records being published

### Step 5: Start the Stream Consumer

Open a **new terminal** and start the consumer to process streaming data.

**Windows:**
```bash
scripts\consumer_spark_submit.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/consumer_spark_submit.sh
./scripts/consumer_spark_submit.sh
```

The consumer will:
- Read from Kafka topic in real-time
- Apply data quality rules (remove null order_id, negative amounts)
- Write cleaned data to Data Lake in Parquet format
- Partition by date (YYYY-MM-DD)
- Display batch processing logs

### Step 6: Verify Pipeline is Working

Check that data is flowing through the pipeline:

**View Kafka messages:**
```bash
docker exec -it food_delivery_kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ROLL001_food_orders_raw --from-beginning
```

**Check Data Lake files:**
```bash
docker exec -it food_delivery_spark_master ls -la /opt/spark-apps/datalake/food/ROLL001/output/orders/
```

You should see date-partitioned directories with Parquet files.

## Testing Incremental Ingestion

### Insert 5 New Records

```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db
```

Then run:
```sql
INSERT INTO ROLL001_orders (customer_name, restaurant_name, item, amount, order_status) VALUES
('Tom Anderson', 'Burger Junction', 'Cheese Burger', 240.00, 'PLACED'),
('Anna Taylor', 'Pizza Palace', 'Veggie Supreme', 380.00, 'PLACED'),
('Chris Martin', 'Sushi World', 'Spicy Tuna Roll', 480.00, 'PLACED'),
('Laura White', 'Taco Bell', 'Beef Quesadilla', 220.00, 'PLACED'),
('Kevin Lee', 'Pasta House', 'Carbonara', 340.00, 'PLACED');
```

Exit psql with `\q`

### Verify Data in Data Lake

Check the parquet files:
```bash
docker exec -it food_delivery_spark_master ls -la /opt/spark-apps/datalake/food/ROLL001/output/orders/
```

### View Data Lake Contents

```bash
docker exec -it food_delivery_spark_master pyspark
```

Then in PySpark shell:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
df.show()
df.count()
df.groupBy("date").count().show()
```

## Monitoring

### Spark UI
- Master: http://localhost:8080
- Application UI: Check the Spark Master UI for running applications

### Kafka Topics

List topics:
```bash
docker exec -it food_delivery_kafka kafka-topics --list --bootstrap-server localhost:9092
```

View messages:
```bash
docker exec -it food_delivery_kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ROLL001_food_orders_raw --from-beginning
```

### PostgreSQL

Connect to database:
```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db
```

View all orders:
```sql
SELECT * FROM ROLL001_orders ORDER BY created_at DESC;
```

## Configuration

All configuration is in `configs/orders_stream.yml`:

- **postgres**: Database connection details
- **kafka**: Kafka broker and topic
- **datalake**: Output path and format
- **streaming**: Checkpoint location, timestamp tracking, batch interval

## Stopping the Pipeline

1. Stop producer and consumer (Ctrl+C in their terminals)
2. Stop all Docker services:
```bash
docker-compose down
```

To remove all data:
```bash
docker-compose down -v
```

## Troubleshooting

### Services not starting
```bash
docker-compose logs <service-name>
# Example: docker-compose logs postgres
```

### Producer/Consumer errors
Check Spark logs in the terminal output

### Kafka connection issues
Ensure Kafka is fully started (takes ~30 seconds after docker-compose up)

### Data not appearing in Data Lake
1. Check producer is running and detecting records
2. Check consumer is running without errors
3. Verify Kafka has messages: `docker exec -it food_delivery_kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ROLL001_food_orders_raw --from-beginning`

## Notes

- Replace `ROLL001` with your actual roll number in:
  - `db/orders.sql` (table name)
  - `configs/orders_stream.yml` (table, topic, paths)
  
- The pipeline uses local file system for Data Lake storage
- For S3 storage, update the config file with S3 paths and add AWS credentials

## Assignment Compliance

This project meets all assignment requirements:
- ✅ PostgreSQL table with 10+ initial records
- ✅ CDC producer using PySpark (polls every 5 seconds)
- ✅ Kafka topic for streaming
- ✅ Spark Structured Streaming consumer
- ✅ Data cleaning (null/negative amount filtering)
- ✅ Parquet format with date partitioning
- ✅ Checkpointing for streaming state
- ✅ Incremental ingestion without duplicates
- ✅ Configuration file (orders_stream.yml)
- ✅ Proper project structure

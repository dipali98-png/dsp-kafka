# System Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     Food Delivery Streaming Pipeline                     │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│              │         │              │         │              │
│  PostgreSQL  │────────▶│     CDC      │────────▶│    Kafka     │
│   Database   │         │   Producer   │         │    Topic     │
│              │         │  (PySpark)   │         │              │
└──────────────┘         └──────────────┘         └──────────────┘
      │                         │                         │
      │                         │                         │
      ▼                         ▼                         ▼
  10 Initial              Polls every              ROLL001_food_
   Records                 5 seconds                orders_raw
                                                         │
                                                         │
                                                         ▼
                                                  ┌──────────────┐
                                                  │    Stream    │
                                                  │   Consumer   │
                                                  │  (PySpark)   │
                                                  └──────────────┘
                                                         │
                                                         │
                                                         ▼
                                                  ┌──────────────┐
                                                  │  Data Lake   │
                                                  │  (Parquet)   │
                                                  │  Partitioned │
                                                  │   by Date    │
                                                  └──────────────┘
```

## Component Details

### 1. PostgreSQL Database
- **Container**: `food_delivery_postgres`
- **Port**: 5432
- **Database**: `food_delivery_db`
- **Table**: `ROLL001_orders`
- **Schema**:
  ```sql
  order_id        SERIAL PRIMARY KEY
  customer_name   VARCHAR(255)
  restaurant_name VARCHAR(255)
  item            VARCHAR(255)
  amount          NUMERIC(10, 2)
  order_status    VARCHAR(50)
  created_at      TIMESTAMP
  ```

### 2. CDC Producer (PySpark)
- **File**: `producers/orders_cdc_producer.py`
- **Function**: Change Data Capture simulation
- **Polling Interval**: 5 seconds
- **Logic**:
  ```
  1. Read last_processed_timestamp from file
  2. Query: SELECT * WHERE created_at > last_timestamp
  3. Convert rows to JSON
  4. Publish to Kafka
  5. Update last_processed_timestamp
  ```
- **State Management**: Stores timestamp in filesystem

### 3. Apache Kafka
- **Broker Container**: `food_delivery_kafka`
- **Zookeeper Container**: `food_delivery_zookeeper`
- **Broker Port**: 9092
- **Topic**: `ROLL001_food_orders_raw`
- **Message Format**:
  ```json
  {
    "order_id": 101,
    "customer_name": "John Doe",
    "restaurant_name": "Burger Junction",
    "item": "Veg Burger",
    "amount": 220.00,
    "order_status": "PLACED",
    "created_at": "2025-01-18T12:24:00Z"
  }
  ```

### 4. Stream Consumer (PySpark)
- **File**: `consumers/orders_stream_consumer.py`
- **Function**: Spark Structured Streaming
- **Processing**:
  ```
  1. Read from Kafka topic
  2. Parse JSON to DataFrame
  3. Data Cleaning:
     - Filter out null order_id
     - Filter out negative amounts
  4. Add date column from created_at
  5. Write to Data Lake (Parquet)
  6. Partition by date
  ```
- **Checkpointing**: Maintains Kafka offsets

### 5. Data Lake
- **Format**: Parquet
- **Location**: `/opt/spark-apps/datalake/food/ROLL001/output/orders/`
- **Partitioning**: By date (YYYY-MM-DD)
- **Structure**:
  ```
  orders/
  ├── date=2025-01-18/
  │   ├── part-00000-xxx.parquet
  │   └── part-00001-xxx.parquet
  ├── date=2025-01-19/
  │   └── part-00000-xxx.parquet
  └── _SUCCESS
  ```

### 6. Apache Spark
- **Master Container**: `food_delivery_spark_master`
- **Worker Container**: `food_delivery_spark_worker`
- **Master Port**: 7077
- **UI Port**: 8080
- **Configuration**:
  - Worker Memory: 2GB
  - Worker Cores: 2
  - Packages: spark-sql-kafka-0-10_2.12:3.5.1

## Data Flow

### Initial Load (10 Records)
```
1. Docker Compose starts PostgreSQL
2. orders.sql automatically executes
3. 10 records inserted with timestamps
4. Ready for CDC processing
```

### Real-Time Streaming
```
1. User inserts new record in PostgreSQL
   └─▶ created_at = CURRENT_TIMESTAMP

2. CDC Producer (every 5 seconds)
   ├─▶ Reads last_processed_timestamp
   ├─▶ Queries: WHERE created_at > last_timestamp
   ├─▶ Converts to JSON
   ├─▶ Publishes to Kafka
   └─▶ Updates last_processed_timestamp

3. Kafka Topic
   └─▶ Stores message in queue

4. Stream Consumer (continuous)
   ├─▶ Reads from Kafka
   ├─▶ Parses JSON
   ├─▶ Filters: order_id NOT NULL AND amount > 0
   ├─▶ Adds date column
   ├─▶ Writes to Parquet
   └─▶ Updates checkpoint

5. Data Lake
   └─▶ Stores in date-partitioned Parquet files
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│              Docker Network: food_delivery_network           │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  PostgreSQL  │  │  Zookeeper   │  │    Kafka     │     │
│  │  :5432       │  │  :2181       │  │  :9092       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐                        │
│  │ Spark Master │  │ Spark Worker │                        │
│  │ :7077, :8080 │  │              │                        │
│  └──────────────┘  └──────────────┘                        │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │                    │                    │
         │                    │                    │
         ▼                    ▼                    ▼
    localhost:5432      localhost:9092      localhost:8080
```

## State Management

### Producer State
- **File**: `last_processed_timestamp_location/last_timestamp.txt`
- **Content**: `2025-01-18 12:33:00`
- **Purpose**: Track last processed record to avoid duplicates

### Consumer State
- **Directory**: `checkpoint_location/`
- **Content**: Kafka offsets, metadata
- **Purpose**: Resume from last processed offset on restart

## Configuration Management

All configuration in `configs/orders_stream.yml`:

```yaml
postgres:
  jdbc_url: "jdbc:postgresql://postgres:5432/food_delivery_db"
  table: "ROLL001_orders"
  user: "student"
  password: "student123"

kafka:
  brokers: "kafka:29092"
  topic: "ROLL001_food_orders_raw"

datalake:
  path: "/opt/spark-apps/datalake/food/ROLL001/output/orders"
  format: "parquet"

streaming:
  checkpoint_location: "/opt/spark-apps/datalake/food/ROLL001/checkpoints/orders"
  last_processed_timestamp_location: "/opt/spark-apps/datalake/food/ROLL001/lastprocess/orders"
  batch_interval: 5
```

## Scalability Considerations

### Horizontal Scaling
- Add more Spark workers: `docker-compose up -d --scale spark-worker=3`
- Add more Kafka brokers for higher throughput
- Partition Kafka topic for parallel processing

### Vertical Scaling
- Increase Spark worker memory/cores
- Increase PostgreSQL resources
- Increase Kafka heap size

## Fault Tolerance

### Producer
- Maintains timestamp file for recovery
- Restarts from last successful position
- No data loss on restart

### Consumer
- Checkpointing ensures exactly-once semantics
- Kafka offset management
- Automatic recovery on failure

### Data Lake
- Append-only writes
- Atomic file operations
- No data corruption on failure

## Monitoring Points

1. **PostgreSQL**: Record count, insert rate
2. **Producer**: Records processed, lag time
3. **Kafka**: Message count, consumer lag
4. **Consumer**: Processing rate, errors
5. **Data Lake**: File count, partition distribution

## Performance Metrics

- **End-to-End Latency**: ~10-15 seconds
  - Producer polling: 5 seconds
  - Kafka propagation: <1 second
  - Consumer processing: 5 seconds
  - File write: <1 second

- **Throughput**: Depends on:
  - Insert rate in PostgreSQL
  - Spark worker resources
  - Kafka partition count

## Security Considerations

- PostgreSQL: Username/password authentication
- Kafka: No authentication (development setup)
- Spark: No authentication (development setup)
- Data Lake: Filesystem permissions

**Note**: For production, implement:
- SSL/TLS encryption
- SASL authentication
- Network policies
- Access control lists

---

This architecture provides a robust, scalable foundation for real-time data streaming from PostgreSQL to a Data Lake using industry-standard tools.

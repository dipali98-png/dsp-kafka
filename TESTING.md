# Testing Guide

Complete testing procedures for the Food Delivery Streaming Pipeline.

## Pre-Test Setup

### 1. Ensure Docker is Running
```bash
docker --version
docker-compose --version
```

### 2. Clean Previous Runs (if any)
```bash
docker-compose down -v
rm -rf datalake/*  # Linux/Mac
# OR
rmdir /s /q datalake  # Windows (if exists)
```

## Test Suite

### Test 1: Infrastructure Setup ✅

**Objective**: Verify all services start correctly

```bash
# Start services
docker-compose up -d

# Wait 30 seconds
# Windows: timeout /t 30 /nobreak
# Linux/Mac: sleep 30

# Check all services are running
docker-compose ps
```

**Expected Result**: All services show "Up" status
- food_delivery_postgres
- food_delivery_zookeeper
- food_delivery_kafka
- food_delivery_spark_master
- food_delivery_spark_worker

**Pass Criteria**: ✅ All 5 services running

---

### Test 2: Database Initialization ✅

**Objective**: Verify table creation and initial data load

```bash
# Check table exists
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "\dt"

# Count records
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) FROM ROLL001_orders;"

# View sample records
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT * FROM ROLL001_orders LIMIT 3;"
```

**Expected Result**: 
- Table `ROLL001_orders` exists
- Count = 10 records
- Records have all 7 columns populated

**Pass Criteria**: ✅ 10 records in database

---

### Test 3: CDC Producer Functionality ✅

**Objective**: Verify producer can read from PostgreSQL and publish to Kafka

```bash
# Terminal 1: Start producer
scripts\producer_spark_submit.bat  # Windows
# OR
./scripts/producer_spark_submit.sh  # Linux/Mac
```

**Expected Output**:
```
Starting CDC Producer for table: ROLL001_orders
Polling for records after: 1970-01-01 00:00:00
Found 10 new records
Published 10 records to Kafka
Updated last processed timestamp to: 2025-01-18 12:33:00
```

**Pass Criteria**: 
- ✅ Producer starts without errors
- ✅ Detects 10 initial records
- ✅ Publishes to Kafka
- ✅ Updates timestamp file

---

### Test 4: Kafka Topic Verification ✅

**Objective**: Verify messages are in Kafka topic

```bash
# List topics
docker exec -it food_delivery_kafka kafka-topics --list --bootstrap-server localhost:9092

# View messages (Ctrl+C after seeing some)
docker exec -it food_delivery_kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ROLL001_food_orders_raw --from-beginning --max-messages 3
```

**Expected Result**:
- Topic `ROLL001_food_orders_raw` exists
- Messages are valid JSON
- Contains order_id, customer_name, etc.

**Pass Criteria**: ✅ Valid JSON messages in Kafka

---

### Test 5: Stream Consumer Functionality ✅

**Objective**: Verify consumer reads from Kafka and writes to Data Lake

```bash
# Terminal 2: Start consumer
scripts\consumer_spark_submit.bat  # Windows
# OR
./scripts/consumer_spark_submit.sh  # Linux/Mac
```

**Expected Output**:
```
Starting Stream Consumer from topic: ROLL001_food_orders_raw
Writing to Data Lake: /opt/spark-apps/datalake/food/ROLL001/output/orders
Stream Consumer started successfully
Waiting for data...
```

**Wait 15 seconds for processing**

**Pass Criteria**: 
- ✅ Consumer starts without errors
- ✅ Connects to Kafka
- ✅ Processes messages

---

### Test 6: Data Lake Verification ✅

**Objective**: Verify Parquet files are created with correct structure

```bash
# Check files exist
docker exec -it food_delivery_spark_master ls -lR /opt/spark-apps/datalake/food/ROLL001/output/orders/

# Read and count records
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
print(f"Total records: {df.count()}")
df.show(5)
df.printSchema()
exit()
```

**Expected Result**:
- Parquet files exist
- Count = 10 records
- Schema matches (order_id, customer_name, etc.)
- Date column exists

**Pass Criteria**: ✅ 10 records in Data Lake

---

### Test 7: Date Partitioning ✅

**Objective**: Verify data is partitioned by date

```bash
# Check partition structure
docker exec -it food_delivery_spark_master ls -la /opt/spark-apps/datalake/food/ROLL001/output/orders/

# Verify in PySpark
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
df.groupBy("date").count().show()
exit()
```

**Expected Result**:
- Directories named `date=YYYY-MM-DD`
- All records grouped by date
- Date derived from created_at

**Pass Criteria**: ✅ Proper date partitioning

---

### Test 8: Incremental Ingestion (First Batch) ✅

**Objective**: Verify new records are detected and processed

**Ensure producer and consumer are still running**

```bash
# Terminal 3: Insert 5 new records
scripts\insert_test_data.bat  # Windows
# OR
./scripts/insert_test_data.sh  # Linux/Mac
```

**Wait 15 seconds**

**Check producer output**: Should show "Found 5 new records"

**Verify in Data Lake**:
```bash
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
print(f"Total records: {df.count()}")  # Should be 15
exit()
```

**Pass Criteria**: ✅ 15 records total (10 + 5)

---

### Test 9: No Duplicates ✅

**Objective**: Verify no duplicate records in Data Lake

```bash
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")

# Check for duplicates
duplicates = df.groupBy("order_id").count().filter("count > 1")
print(f"Duplicate count: {duplicates.count()}")  # Should be 0
duplicates.show()

# Verify unique order_ids
print(f"Total records: {df.count()}")
print(f"Unique order_ids: {df.select('order_id').distinct().count()}")
# Both should be equal

exit()
```

**Pass Criteria**: ✅ No duplicates found

---

### Test 10: Incremental Ingestion (Second Batch) ✅

**Objective**: Verify continued incremental processing

```bash
# Insert 5 more records manually
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db
```

In psql:
```sql
INSERT INTO ROLL001_orders (customer_name, restaurant_name, item, amount, order_status) VALUES
('Alice Johnson', 'Burger Junction', 'Fish Burger', 260.00, 'PLACED'),
('Bob Smith', 'Pizza Palace', 'BBQ Chicken Pizza', 420.00, 'PLACED'),
('Carol White', 'Sushi World', 'Rainbow Roll', 520.00, 'PLACED'),
('David Lee', 'Taco Bell', 'Steak Burrito', 280.00, 'PLACED'),
('Eve Brown', 'Pasta House', 'Lasagna', 360.00, 'PLACED');

\q
```

**Wait 15 seconds**

**Verify in Data Lake**:
```bash
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
print(f"Total records: {df.count()}")  # Should be 20
exit()
```

**Pass Criteria**: ✅ 20 records total (10 + 5 + 5)

---

### Test 11: Data Cleaning ✅

**Objective**: Verify null and negative amount filtering

```bash
# Insert records with null and negative values
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db
```

In psql:
```sql
-- This should be filtered out (negative amount)
INSERT INTO ROLL001_orders (customer_name, restaurant_name, item, amount, order_status) 
VALUES ('Test User', 'Test Restaurant', 'Test Item', -100.00, 'PLACED');

-- Check it was inserted in PostgreSQL
SELECT COUNT(*) FROM ROLL001_orders;  -- Should be 21

\q
```

**Wait 15 seconds**

**Verify in Data Lake**:
```bash
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
print(f"Total records: {df.count()}")  # Should still be 20 (negative filtered)

# Verify no negative amounts
negative = df.filter("amount < 0")
print(f"Negative amounts: {negative.count()}")  # Should be 0

exit()
```

**Pass Criteria**: ✅ Negative amounts filtered out

---

### Test 12: State Persistence ✅

**Objective**: Verify timestamp tracking works

```bash
# Check last processed timestamp
docker exec -it food_delivery_spark_master cat /opt/spark-apps/datalake/food/ROLL001/lastprocess/orders/last_timestamp.txt
```

**Expected Result**: Shows latest timestamp from processed records

**Pass Criteria**: ✅ Timestamp file exists and is updated

---

### Test 13: Checkpoint Verification ✅

**Objective**: Verify Spark checkpointing works

```bash
# Check checkpoint directory
docker exec -it food_delivery_spark_master ls -lR /opt/spark-apps/datalake/food/ROLL001/checkpoints/orders/
```

**Expected Result**: 
- Directory exists
- Contains offsets and metadata files

**Pass Criteria**: ✅ Checkpoint files exist

---

### Test 14: Recovery Test ✅

**Objective**: Verify pipeline recovers after restart

```bash
# Stop consumer (Ctrl+C in Terminal 2)

# Insert new record
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "INSERT INTO ROLL001_orders (customer_name, restaurant_name, item, amount, order_status) VALUES ('Recovery Test', 'Test Restaurant', 'Test Item', 100.00, 'PLACED');"

# Wait for producer to process (check Terminal 1)

# Restart consumer
scripts\consumer_spark_submit.bat  # Windows
# OR
./scripts/consumer_spark_submit.sh  # Linux/Mac

# Wait 15 seconds

# Verify record is in Data Lake
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
df.filter("customer_name = 'Recovery Test'").show()
exit()
```

**Pass Criteria**: ✅ Record processed after restart

---

### Test 15: End-to-End Latency ✅

**Objective**: Measure end-to-end processing time

```bash
# Note current time
# Insert record
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "INSERT INTO ROLL001_orders (customer_name, restaurant_name, item, amount, order_status) VALUES ('Latency Test', 'Test Restaurant', 'Test Item', 100.00, 'PLACED');"

# Watch producer log (Terminal 1) - note when it detects the record
# Watch consumer log (Terminal 2) - note when it processes

# Check Data Lake
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
df.filter("customer_name = 'Latency Test'").show()
exit()
```

**Expected Latency**: 10-15 seconds

**Pass Criteria**: ✅ Record appears within 20 seconds

---

## Automated Validation

Run the complete validation script:

```bash
# Windows
scripts\validate_pipeline.bat

# Linux/Mac
./scripts/validate_pipeline.sh
```

This checks:
1. PostgreSQL record count
2. Kafka messages
3. Data Lake files
4. Checkpoint location
5. Last processed timestamp

---

## Test Summary Checklist

- [ ] Test 1: Infrastructure Setup
- [ ] Test 2: Database Initialization
- [ ] Test 3: CDC Producer Functionality
- [ ] Test 4: Kafka Topic Verification
- [ ] Test 5: Stream Consumer Functionality
- [ ] Test 6: Data Lake Verification
- [ ] Test 7: Date Partitioning
- [ ] Test 8: Incremental Ingestion (First Batch)
- [ ] Test 9: No Duplicates
- [ ] Test 10: Incremental Ingestion (Second Batch)
- [ ] Test 11: Data Cleaning
- [ ] Test 12: State Persistence
- [ ] Test 13: Checkpoint Verification
- [ ] Test 14: Recovery Test
- [ ] Test 15: End-to-End Latency

---

## Troubleshooting Failed Tests

### Test 1 Failed: Services not starting
```bash
docker-compose down -v
docker system prune -f
docker-compose up -d
```

### Test 2 Failed: No data in PostgreSQL
```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -f /docker-entrypoint-initdb.d/orders.sql
```

### Test 3 Failed: Producer errors
- Check PostgreSQL connection in config
- Verify table name matches
- Check logs: `docker-compose logs food_delivery_postgres`

### Test 4 Failed: No Kafka messages
- Ensure producer ran successfully
- Check Kafka is running: `docker-compose ps kafka`
- Verify topic name in config

### Test 5 Failed: Consumer errors
- Check Kafka connection
- Verify topic exists
- Check checkpoint location is writable

### Test 6 Failed: No Data Lake files
- Ensure consumer ran for at least 15 seconds
- Check consumer logs for errors
- Verify path in config

### Test 9 Failed: Duplicates found
- Check timestamp file is being updated
- Verify producer logic
- Clear Data Lake and restart

---

## Performance Benchmarks

Expected performance on standard hardware:

| Metric | Value |
|--------|-------|
| Startup Time | 30-60 seconds |
| Producer Polling | 5 seconds |
| Consumer Processing | 5 seconds |
| End-to-End Latency | 10-15 seconds |
| Throughput | ~12 records/minute |

---

## Clean Up After Testing

```bash
# Stop producer and consumer (Ctrl+C)

# Stop all services
docker-compose down

# Remove all data (optional)
docker-compose down -v
```

---

**All tests passing? ✅ Your pipeline is ready for submission!**

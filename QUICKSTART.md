# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Start Services (1 minute)
```bash
# Windows
start.bat

# Linux/Mac
chmod +x start.sh
./start.sh
```

Wait for all services to start (about 30 seconds).

### Step 2: Start Producer (Terminal 1)
```bash
# Windows
scripts\producer_spark_submit.bat

# Linux/Mac
chmod +x scripts/producer_spark_submit.sh
./scripts/producer_spark_submit.sh
```

Wait until you see: "Starting CDC Producer for table: ROLL001_orders"

### Step 3: Start Consumer (Terminal 2)
```bash
# Windows
scripts\consumer_spark_submit.bat

# Linux/Mac
chmod +x scripts/consumer_spark_submit.sh
./scripts/consumer_spark_submit.sh
```

Wait until you see: "Stream Consumer started successfully"

### Step 4: Test with New Data (Terminal 3)
```bash
# Windows
scripts\insert_test_data.bat

# Linux/Mac
chmod +x scripts/insert_test_data.sh
./scripts/insert_test_data.sh
```

### Step 5: Validate Results
```bash
# Windows
scripts\validate_pipeline.bat

# Linux/Mac
chmod +x scripts/validate_pipeline.sh
./scripts/validate_pipeline.sh
```

## 📊 View Results

### Check Data Lake
```bash
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
df.show()
print(f"Total records: {df.count()}")
df.groupBy("date").count().show()
```

### Check PostgreSQL
```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db
```

In psql:
```sql
SELECT COUNT(*) FROM ROLL001_orders;
SELECT * FROM ROLL001_orders ORDER BY created_at DESC LIMIT 10;
\q
```

## 🛑 Stop Everything
```bash
# Stop producer and consumer (Ctrl+C in their terminals)
# Then stop Docker services:
docker-compose down
```

## 🔧 Troubleshooting

### Services won't start?
```bash
docker-compose down -v
docker-compose up -d
```

### Producer/Consumer errors?
Make sure all services are running:
```bash
docker-compose ps
```

All should show "Up" status.

### No data in Data Lake?
1. Check producer is running and detecting records
2. Check consumer is running
3. Wait 10-15 seconds after inserting data
4. Run validation script

## 📝 Important Notes

- **First run**: Initial setup takes ~1 minute
- **Producer polls**: Every 5 seconds
- **Consumer processes**: Every 5 seconds
- **Data appears**: Within 10-15 seconds of insertion

## 🎯 Assignment Requirements Checklist

- ✅ PostgreSQL with 10 initial records
- ✅ CDC Producer (PySpark) polling every 5 seconds
- ✅ Kafka topic for streaming
- ✅ Spark Structured Streaming consumer
- ✅ Data cleaning (null/negative filtering)
- ✅ Parquet format with date partitioning
- ✅ Checkpointing for state management
- ✅ Incremental ingestion without duplicates
- ✅ Configuration file (orders_stream.yml)
- ✅ Proper project structure

## 🔄 Testing Incremental Ingestion

1. Start producer and consumer
2. Insert 5 records → Validate count
3. Insert 5 more records → Validate count increased
4. Check no duplicates in Data Lake
5. Verify partitioning by date

## 📦 What's Included

- **Docker Compose**: All services containerized
- **PostgreSQL**: Database with sample data
- **Kafka + Zookeeper**: Message streaming
- **Spark**: Distributed processing
- **Python Scripts**: Producer and Consumer
- **Helper Scripts**: Easy start/stop/test
- **Documentation**: Complete guides

## 🎓 For Submission

Replace `ROLL001` with your roll number in:
1. `db/orders.sql` - table name
2. `configs/orders_stream.yml` - all occurrences
3. Run the pipeline
4. Zip the folder
5. Submit!

---

**Need help?** Check README.md for detailed documentation.

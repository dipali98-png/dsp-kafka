# Deployment & Submission Guide

## Pre-Submission Checklist

### 1. Update Roll Number
Replace `ROLL001` with your actual roll number in these files:

- [ ] `db/orders.sql` - Line 2: Table name
- [ ] `db/insert_test_data.sql` - Line 4: Table name
- [ ] `configs/orders_stream.yml` - Lines 8, 12, 15, 18, 19

**Quick Find & Replace:**
- Find: `ROLL001`
- Replace: `YOUR_ROLL_NUMBER`

### 2. Test the Complete Pipeline

```bash
# Step 1: Start services
docker-compose up -d

# Step 2: Wait 30 seconds for services to initialize

# Step 3: Verify database
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) FROM YOUR_ROLL_NUMBER_orders;"
# Expected: 10 records

# Step 4: Start producer (Terminal 1)
scripts/producer_spark_submit.bat  # Windows
# OR
./scripts/producer_spark_submit.sh  # Linux/Mac

# Step 5: Start consumer (Terminal 2)
scripts/consumer_spark_submit.bat  # Windows
# OR
./scripts/consumer_spark_submit.sh  # Linux/Mac

# Step 6: Insert test data (Terminal 3)
scripts/insert_test_data.bat  # Windows
# OR
./scripts/insert_test_data.sh  # Linux/Mac

# Step 7: Wait 15 seconds

# Step 8: Validate
scripts/validate_pipeline.bat  # Windows
# OR
./scripts/validate_pipeline.sh  # Linux/Mac
```

### 3. Verify Data Lake Output

```bash
docker exec -it food_delivery_spark_master pyspark
```

In PySpark:
```python
# Read parquet files
df = spark.read.parquet("/opt/spark-apps/datalake/food/YOUR_ROLL_NUMBER/output/orders/")

# Should show 15 records (10 initial + 5 test)
print(f"Total records: {df.count()}")

# Verify partitioning by date
df.groupBy("date").count().show()

# Check for duplicates
df.groupBy("order_id").count().filter("count > 1").show()
# Should be empty (no duplicates)

# Exit
exit()
```

### 4. Clean Up for Submission

```bash
# Stop all services
docker-compose down

# Remove generated data (optional - if you want clean submission)
# rm -rf datalake/*  # Linux/Mac
# rmdir /s /q datalake  # Windows
```

## Submission Package Structure

Your final submission should have this structure:

```
YOUR_ROLL_NUMBER/
└── food_delivery_streaming/
    └── local/
        ├── db/
        │   ├── orders.sql
        │   └── insert_test_data.sql
        ├── producers/
        │   └── orders_cdc_producer.py
        ├── consumers/
        │   └── orders_stream_consumer.py
        ├── scripts/
        │   ├── producer_spark_submit.sh
        │   ├── consumer_spark_submit.sh
        │   ├── producer_spark_submit.bat
        │   ├── consumer_spark_submit.bat
        │   ├── insert_test_data.sh
        │   ├── insert_test_data.bat
        │   ├── validate_pipeline.sh
        │   └── validate_pipeline.bat
        ├── configs/
        │   └── orders_stream.yml
        ├── docker-compose.yml
        ├── requirements.txt
        ├── start.sh
        ├── start.bat
        ├── README.md
        ├── QUICKSTART.md
        └── DEPLOYMENT.md
```

## Creating Submission ZIP

### Windows:
```bash
# Create folder structure
mkdir YOUR_ROLL_NUMBER\food_delivery_streaming\local
xcopy /E /I . YOUR_ROLL_NUMBER\food_delivery_streaming\local

# Exclude unnecessary files
cd YOUR_ROLL_NUMBER\food_delivery_streaming\local
rmdir /s /q datalake
rmdir /s /q inputs
del .gitignore
del Dockerfile.spark

# Create ZIP
# Right-click on YOUR_ROLL_NUMBER folder → Send to → Compressed (zipped) folder
```

### Linux/Mac:
```bash
# Create folder structure
mkdir -p YOUR_ROLL_NUMBER/food_delivery_streaming/local
cp -r . YOUR_ROLL_NUMBER/food_delivery_streaming/local/

# Exclude unnecessary files
cd YOUR_ROLL_NUMBER/food_delivery_streaming/local
rm -rf datalake inputs .gitignore Dockerfile.spark

# Create ZIP
cd ../../..
zip -r YOUR_ROLL_NUMBER.zip YOUR_ROLL_NUMBER/
```

## Instructor Evaluation Process

The instructor will:

1. **Extract your ZIP file**
2. **Navigate to the project directory**
3. **Start services:**
   ```bash
   docker-compose up -d
   ```
4. **Verify initial data:**
   ```bash
   docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) FROM YOUR_ROLL_NUMBER_orders;"
   ```
5. **Start producer and consumer**
6. **Insert 5 test records**
7. **Validate Data Lake has 15 records**
8. **Insert 5 more records**
9. **Validate Data Lake has 20 records**
10. **Check for duplicates**
11. **Verify date partitioning**

## Key Evaluation Criteria

- ✅ **Correctness**: All 10 initial records in PostgreSQL
- ✅ **CDC Producer**: Polls every 5 seconds, detects new records
- ✅ **Kafka Integration**: Messages published to correct topic
- ✅ **Stream Consumer**: Reads from Kafka, processes continuously
- ✅ **Data Cleaning**: Null order_id and negative amounts filtered
- ✅ **Data Lake**: Parquet format, date partitioned
- ✅ **Incremental Ingestion**: No duplicates, only new records processed
- ✅ **Checkpointing**: Streaming state maintained
- ✅ **Configuration**: All parameters in orders_stream.yml
- ✅ **Project Structure**: Follows assignment requirements

## Common Issues & Solutions

### Issue: Services not starting
**Solution:**
```bash
docker-compose down -v
docker-compose up -d
```

### Issue: Producer can't connect to PostgreSQL
**Solution:** Check `configs/orders_stream.yml` has correct connection details

### Issue: Consumer not receiving messages
**Solution:** 
1. Verify Kafka topic exists
2. Check producer is running
3. Ensure consumer is reading from correct topic

### Issue: No data in Data Lake
**Solution:**
1. Check consumer logs for errors
2. Verify checkpoint location is writable
3. Ensure data cleaning filters aren't removing all records

### Issue: Duplicates in Data Lake
**Solution:**
1. Check last_processed_timestamp is being updated
2. Verify producer is using correct timestamp comparison
3. Ensure checkpoint is working properly

## Docker Commands Reference

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Restart a service
docker-compose restart [service-name]

# Check service status
docker-compose ps

# Remove all data
docker-compose down -v

# Execute command in container
docker exec -it [container-name] [command]
```

## Final Checklist Before Submission

- [ ] Roll number updated in all files
- [ ] Tested complete pipeline end-to-end
- [ ] Verified 10 initial records in PostgreSQL
- [ ] Confirmed incremental ingestion works
- [ ] Checked no duplicates in Data Lake
- [ ] Verified date partitioning
- [ ] README.md is complete and accurate
- [ ] All scripts are executable
- [ ] Configuration file has correct values
- [ ] Project structure matches requirements
- [ ] ZIP file created with correct structure
- [ ] ZIP file name is YOUR_ROLL_NUMBER.zip

## Support

If you encounter issues:
1. Check README.md for detailed documentation
2. Review QUICKSTART.md for step-by-step guide
3. Run validation script to identify problems
4. Check Docker logs for error messages

---

**Good luck with your submission! 🚀**

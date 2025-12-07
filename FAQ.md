# Frequently Asked Questions (FAQ)

## General Questions

### Q1: What is this project about?
**A:** This is a real-time streaming pipeline that captures food delivery orders from PostgreSQL, streams them through Kafka, processes them with Spark, and stores them in a Data Lake in Parquet format.

### Q2: Do I need to install anything besides Docker?
**A:** No! Everything runs in Docker containers. You only need Docker Desktop installed and running.

### Q3: What operating systems are supported?
**A:** Windows, Linux, and macOS. Scripts are provided for both Windows (.bat) and Unix (.sh).

### Q4: How long does it take to set up?
**A:** About 5 minutes for first-time setup, 1 minute for subsequent runs.

---

## Setup & Installation

### Q5: Docker Compose fails to start services. What should I do?
**A:** 
```bash
# Clean everything and restart
docker-compose down -v
docker system prune -f
docker-compose up -d
```

### Q6: Services are running but I can't connect to them
**A:** Wait 30-60 seconds after `docker-compose up -d`. Services need time to initialize, especially Kafka.

### Q7: PostgreSQL container keeps restarting
**A:** Check if port 5432 is already in use:
```bash
# Windows
netstat -ano | findstr :5432

# Linux/Mac
lsof -i :5432
```
Stop any conflicting service or change the port in docker-compose.yml.

### Q8: How much disk space do I need?
**A:** Minimum 5GB free space for Docker images and data.

### Q9: How much RAM is required?
**A:** Minimum 8GB RAM, with at least 4GB allocated to Docker.

---

## Configuration

### Q10: How do I change my roll number?
**A:** Replace `ROLL001` in these files:
- `db/orders.sql` (line 2)
- `db/insert_test_data.sql` (line 4)
- `configs/orders_stream.yml` (lines 8, 12, 15, 18, 19)

### Q11: Can I change the polling interval?
**A:** Yes, in `configs/orders_stream.yml`:
```yaml
streaming:
  batch_interval: 5  # Change to desired seconds
```

### Q12: How do I use S3 instead of local storage?
**A:** Update `configs/orders_stream.yml`:
```yaml
datalake:
  path: "s3://your-bucket/path/to/orders"
```
And add AWS credentials to Spark configuration.

### Q13: Can I change the Kafka topic name?
**A:** Yes, in `configs/orders_stream.yml`:
```yaml
kafka:
  topic: "your_custom_topic_name"
```

---

## Running the Pipeline

### Q14: In what order should I start the components?
**A:**
1. Start Docker services: `docker-compose up -d`
2. Wait 30 seconds
3. Start producer: `scripts/producer_spark_submit.bat`
4. Start consumer: `scripts/consumer_spark_submit.bat`
5. Insert test data: `scripts/insert_test_data.bat`

### Q15: Can I run producer and consumer on the same terminal?
**A:** No, they need separate terminals as both are long-running processes.

### Q16: How do I know if the producer is working?
**A:** You'll see output like:
```
Found X new records
Published X records to Kafka
Updated last processed timestamp to: ...
```

### Q17: How do I know if the consumer is working?
**A:** You'll see:
```
Stream Consumer started successfully
Waiting for data...
```
And no error messages.

### Q18: How long does it take for data to appear in the Data Lake?
**A:** 10-15 seconds after inserting into PostgreSQL.

---

## Data & Testing

### Q19: How do I verify data is in PostgreSQL?
**A:**
```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -c "SELECT COUNT(*) FROM ROLL001_orders;"
```

### Q20: How do I check if messages are in Kafka?
**A:**
```bash
docker exec -it food_delivery_kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ROLL001_food_orders_raw --from-beginning --max-messages 5
```

### Q21: How do I view data in the Data Lake?
**A:**
```bash
docker exec -it food_delivery_spark_master pyspark
```
Then:
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
df.show()
df.count()
```

### Q22: I inserted data but it's not in the Data Lake. Why?
**A:** Check:
1. Producer is running and detected the record
2. Consumer is running without errors
3. Wait 15 seconds for processing
4. Check if data was filtered (null order_id or negative amount)

### Q23: How do I check for duplicates?
**A:**
```python
df = spark.read.parquet("/opt/spark-apps/datalake/food/ROLL001/output/orders/")
duplicates = df.groupBy("order_id").count().filter("count > 1")
duplicates.show()  # Should be empty
```

### Q24: How do I verify date partitioning?
**A:**
```bash
docker exec -it food_delivery_spark_master ls -la /opt/spark-apps/datalake/food/ROLL001/output/orders/
```
You should see directories like `date=2025-01-18/`

---

## Troubleshooting

### Q25: Producer says "Connection refused" to PostgreSQL
**A:** 
- Ensure PostgreSQL container is running: `docker-compose ps`
- Check connection details in `configs/orders_stream.yml`
- Verify network: `docker network ls`

### Q26: Consumer says "Connection refused" to Kafka
**A:**
- Wait 30 seconds after starting Kafka
- Check Kafka is running: `docker-compose ps kafka`
- Verify broker address in config: `kafka:29092` (not localhost)

### Q27: "Table does not exist" error
**A:**
- Check table name matches in config and SQL file
- Verify database initialization: `docker-compose logs postgres`
- Manually run: `docker exec -it food_delivery_postgres psql -U student -d food_delivery_db -f /docker-entrypoint-initdb.d/orders.sql`

### Q28: Spark job fails with "Out of Memory"
**A:** Increase worker memory in docker-compose.yml:
```yaml
spark-worker:
  environment:
    - SPARK_WORKER_MEMORY=4G  # Increase from 2G
```

### Q29: Data Lake files are empty
**A:**
- Check consumer logs for errors
- Verify data isn't being filtered out
- Ensure checkpoint location is writable

### Q30: I see duplicates in the Data Lake
**A:**
- Check last_timestamp.txt is being updated
- Verify producer logic
- Clear Data Lake and restart: `docker exec -it food_delivery_spark_master rm -rf /opt/spark-apps/datalake/food/ROLL001/output/orders/*`

---

## Performance

### Q31: The pipeline is slow. How can I speed it up?
**A:**
- Reduce batch_interval (but not below 2 seconds)
- Add more Spark workers: `docker-compose up -d --scale spark-worker=3`
- Increase worker resources in docker-compose.yml

### Q32: What's the expected throughput?
**A:** With default settings (5-second polling), approximately 12 records per minute.

### Q33: What's the expected latency?
**A:** 10-15 seconds end-to-end (insert to Data Lake).

### Q34: Can this handle high-volume data?
**A:** Yes, with adjustments:
- Increase Spark workers
- Partition Kafka topic
- Reduce batch interval
- Increase worker memory/cores

---

## Monitoring

### Q35: How do I view Spark UI?
**A:** Open http://localhost:8080 in your browser.

### Q36: How do I check service logs?
**A:**
```bash
docker-compose logs -f [service-name]
# Example: docker-compose logs -f kafka
```

### Q37: How do I monitor Kafka lag?
**A:**
```bash
docker exec -it food_delivery_kafka kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group [consumer-group-id]
```

### Q38: Where are the checkpoint files?
**A:** `/opt/spark-apps/datalake/food/ROLL001/checkpoints/orders/`

### Q39: Where is the last processed timestamp stored?
**A:** `/opt/spark-apps/datalake/food/ROLL001/lastprocess/orders/last_timestamp.txt`

---

## Submission

### Q40: What files should I include in the submission?
**A:** Everything except:
- `datalake/` (generated at runtime)
- `inputs/` (assignment materials)
- `.gitignore`
- `Dockerfile.spark` (optional)

### Q41: What's the correct folder structure for submission?
**A:**
```
YOUR_ROLL_NUMBER/
└── food_delivery_streaming/
    └── local/
        ├── db/
        ├── producers/
        ├── consumers/
        ├── scripts/
        ├── configs/
        ├── docker-compose.yml
        └── README.md
```

### Q42: How do I create the submission ZIP?
**A:** See [DEPLOYMENT.md](DEPLOYMENT.md#creating-submission-zip)

### Q43: Should I include the data in the submission?
**A:** No, only include the code and configuration. The evaluator will generate data by running the pipeline.

### Q44: What if my roll number has special characters?
**A:** Use only alphanumeric characters. Example: `ROLL001` not `ROLL-001`

---

## Advanced

### Q45: Can I use this with a real CDC tool like Debezium?
**A:** Yes! Replace the producer with Debezium Kafka Connect.

### Q46: Can I add data transformations?
**A:** Yes, modify `orders_stream_consumer.py` to add transformations before writing to Data Lake.

### Q47: Can I write to multiple sinks?
**A:** Yes, use `foreachBatch` in the consumer to write to multiple destinations.

### Q48: Can I use this with AWS EMR?
**A:** Yes, but you'll need to:
- Use S3 for Data Lake
- Configure EMR cluster
- Update Spark submit commands

### Q49: How do I add authentication?
**A:** For production:
- Enable PostgreSQL SSL
- Configure Kafka SASL/SSL
- Implement Spark authentication
- Use secrets management

### Q50: Can I run this without Docker?
**A:** Yes, but you'll need to:
- Install PostgreSQL, Kafka, Zookeeper, Spark locally
- Update connection strings in config
- Manage services manually

---

## Debugging

### Q51: How do I debug the producer?
**A:** Add print statements and check terminal output. Also check:
```bash
docker-compose logs postgres
```

### Q52: How do I debug the consumer?
**A:** Check Spark logs in terminal and Spark UI (http://localhost:8080).

### Q53: How do I reset everything?
**A:**
```bash
# Stop and remove everything
docker-compose down -v

# Remove data
docker exec -it food_delivery_spark_master rm -rf /opt/spark-apps/datalake/food/ROLL001/

# Restart
docker-compose up -d
```

### Q54: How do I test without Docker?
**A:** Not recommended, but you can:
- Install all services locally
- Update configs with localhost
- Run scripts manually

### Q55: How do I enable debug logging?
**A:** Add to Spark submit commands:
```bash
--conf spark.sql.streaming.metricsEnabled=true
--conf spark.eventLog.enabled=true
```

---

## Best Practices

### Q56: Should I commit the datalake folder to Git?
**A:** No, it's in .gitignore. It's generated at runtime.

### Q57: How often should I checkpoint?
**A:** Default settings are fine. Checkpointing happens automatically.

### Q58: Should I use local or S3 for Data Lake?
**A:** 
- **Local**: Easier for development and testing
- **S3**: Better for production and sharing

### Q59: What's the best batch interval?
**A:** 5 seconds is good for development. For production, adjust based on:
- Data volume
- Latency requirements
- Resource availability

### Q60: Should I scale Spark workers?
**A:** 
- **1 worker**: Fine for development
- **2-3 workers**: Better for testing with larger data
- **3+ workers**: Production with high volume

---

## Common Errors

### Q61: "Address already in use"
**A:** Port conflict. Stop the conflicting service or change port in docker-compose.yml.

### Q62: "No space left on device"
**A:** Clean Docker:
```bash
docker system prune -a -f
docker volume prune -f
```

### Q63: "Permission denied"
**A:** 
- Windows: Run as Administrator
- Linux/Mac: Use `sudo` or fix permissions

### Q64: "Cannot connect to Docker daemon"
**A:** Start Docker Desktop.

### Q65: "Network not found"
**A:**
```bash
docker-compose down
docker network prune -f
docker-compose up -d
```

---

## Still Have Questions?

1. Check the documentation:
   - [README.md](README.md) - Complete guide
   - [QUICKSTART.md](QUICKSTART.md) - Quick start
   - [TESTING.md](TESTING.md) - Testing guide
   - [DEPLOYMENT.md](DEPLOYMENT.md) - Submission guide

2. Check logs:
   ```bash
   docker-compose logs -f [service-name]
   ```

3. Validate your setup:
   ```bash
   scripts/validate_pipeline.bat  # Windows
   ./scripts/validate_pipeline.sh  # Linux/Mac
   ```

4. Review test cases in [TESTING.md](TESTING.md)

---

**Can't find your question? Check the documentation index: [INDEX.md](INDEX.md)**

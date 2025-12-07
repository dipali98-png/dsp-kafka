# 📚 Documentation Index

Welcome to the Food Delivery Streaming Pipeline project! This index will help you find the right documentation for your needs.

## 🚀 Getting Started

**New to the project? Start here:**

1. **[QUICKSTART.md](QUICKSTART.md)** - Get up and running in 5 minutes
   - Quick setup steps
   - Basic commands
   - First test run

2. **[README.md](README.md)** - Complete project documentation
   - Detailed setup instructions
   - Usage guide
   - Troubleshooting
   - Monitoring

## 📖 Understanding the Project

**Want to understand how it works?**

3. **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - High-level overview
   - What's included
   - Key features
   - Technical stack
   - Requirements checklist

4. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical deep dive
   - System architecture diagrams
   - Component details
   - Data flow
   - Network architecture
   - State management

## 🧪 Testing & Validation

**Ready to test?**

5. **[TESTING.md](TESTING.md)** - Comprehensive testing guide
   - 15 detailed test cases
   - Validation procedures
   - Performance benchmarks
   - Troubleshooting failed tests

## 📦 Deployment & Submission

**Preparing for submission?**

6. **[DEPLOYMENT.md](DEPLOYMENT.md)** - Submission guide
   - Pre-submission checklist
   - Roll number update instructions
   - Validation steps
   - ZIP creation guide
   - Evaluation process

## 📁 Project Files

### Core Application Files

| File | Purpose | Documentation |
|------|---------|---------------|
| `db/orders.sql` | Database schema + initial data | [README.md](README.md#database-setup) |
| `producers/orders_cdc_producer.py` | CDC Producer (PySpark) | [ARCHITECTURE.md](ARCHITECTURE.md#cdc-producer) |
| `consumers/orders_stream_consumer.py` | Stream Consumer (PySpark) | [ARCHITECTURE.md](ARCHITECTURE.md#stream-consumer) |
| `configs/orders_stream.yml` | Configuration file | [README.md](README.md#configuration) |

### Infrastructure Files

| File | Purpose | Documentation |
|------|---------|---------------|
| `docker-compose.yml` | Docker services definition | [README.md](README.md#docker-setup) |
| `Dockerfile.spark` | Custom Spark image (optional) | [README.md](README.md#custom-docker-image) |
| `requirements.txt` | Python dependencies | [README.md](README.md#dependencies) |

### Helper Scripts

| Script | Purpose | Platform |
|--------|---------|----------|
| `start.bat` / `start.sh` | Start all services | Windows / Linux-Mac |
| `scripts/producer_spark_submit.*` | Start CDC producer | Both |
| `scripts/consumer_spark_submit.*` | Start stream consumer | Both |
| `scripts/insert_test_data.*` | Insert test records | Both |
| `scripts/validate_pipeline.*` | Validate pipeline | Both |

### Test Data

| File | Purpose |
|------|---------|
| `db/orders.sql` | 10 initial records |
| `db/insert_test_data.sql` | 5 test records |

## 🎯 Quick Reference by Task

### "I want to set up the project"
→ [QUICKSTART.md](QUICKSTART.md) or [README.md](README.md)

### "I want to understand the architecture"
→ [ARCHITECTURE.md](ARCHITECTURE.md)

### "I want to test the pipeline"
→ [TESTING.md](TESTING.md)

### "I want to prepare for submission"
→ [DEPLOYMENT.md](DEPLOYMENT.md)

### "I want a project overview"
→ [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)

### "I need troubleshooting help"
→ [README.md](README.md#troubleshooting) or [TESTING.md](TESTING.md#troubleshooting-failed-tests)

### "I want to customize the project"
→ [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md#customization-options)

## 🔍 Quick Search

### Commands

**Start Services:**
```bash
# Windows
start.bat

# Linux/Mac
./start.sh
```

**Start Producer:**
```bash
# Windows
scripts\producer_spark_submit.bat

# Linux/Mac
./scripts/producer_spark_submit.sh
```

**Start Consumer:**
```bash
# Windows
scripts\consumer_spark_submit.bat

# Linux/Mac
./scripts/consumer_spark_submit.sh
```

**Insert Test Data:**
```bash
# Windows
scripts\insert_test_data.bat

# Linux/Mac
./scripts/insert_test_data.sh
```

**Validate Pipeline:**
```bash
# Windows
scripts\validate_pipeline.bat

# Linux/Mac
./scripts/validate_pipeline.sh
```

**Stop Services:**
```bash
docker-compose down
```

### Configuration

**Update Roll Number:**
- `db/orders.sql` - Line 2
- `db/insert_test_data.sql` - Line 4
- `configs/orders_stream.yml` - Lines 8, 12, 15, 18, 19

**Change Polling Interval:**
- `configs/orders_stream.yml` - `streaming.batch_interval`

**Change Data Lake Path:**
- `configs/orders_stream.yml` - `datalake.path`

### Monitoring

**Spark UI:** http://localhost:8080

**PostgreSQL:**
```bash
docker exec -it food_delivery_postgres psql -U student -d food_delivery_db
```

**Kafka Messages:**
```bash
docker exec -it food_delivery_kafka kafka-console-consumer --bootstrap-server localhost:9092 --topic ROLL001_food_orders_raw --from-beginning
```

**Data Lake:**
```bash
docker exec -it food_delivery_spark_master pyspark
```

## 📊 Project Statistics

- **Total Files**: 20+
- **Lines of Code**: 500+
- **Documentation Pages**: 7
- **Test Cases**: 15
- **Docker Services**: 5
- **Technologies**: 6 (PostgreSQL, Kafka, Spark, Docker, Python, YAML)

## 🎓 Learning Path

**Recommended reading order for learning:**

1. **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Understand what you're building
2. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Learn how it works
3. **[QUICKSTART.md](QUICKSTART.md)** - Get hands-on experience
4. **[TESTING.md](TESTING.md)** - Validate your understanding
5. **[DEPLOYMENT.md](DEPLOYMENT.md)** - Prepare for submission

## 🆘 Help & Support

### Common Questions

**Q: Services won't start?**  
A: See [README.md - Troubleshooting](README.md#troubleshooting)

**Q: No data in Data Lake?**  
A: See [TESTING.md - Test 6](TESTING.md#test-6-data-lake-verification)

**Q: How to check for duplicates?**  
A: See [TESTING.md - Test 9](TESTING.md#test-9-no-duplicates)

**Q: How to update roll number?**  
A: See [DEPLOYMENT.md - Update Roll Number](DEPLOYMENT.md#1-update-roll-number)

**Q: How to create submission ZIP?**  
A: See [DEPLOYMENT.md - Creating Submission ZIP](DEPLOYMENT.md#creating-submission-zip)

## 📝 Document Summaries

### README.md (Main Documentation)
- Complete setup guide
- Usage instructions
- Configuration details
- Monitoring commands
- Troubleshooting

### QUICKSTART.md (5-Minute Guide)
- Fastest way to get started
- Essential commands only
- Quick validation
- Minimal explanation

### PROJECT_SUMMARY.md (Overview)
- High-level project description
- Key features
- Technical stack
- Requirements checklist
- Use cases

### ARCHITECTURE.md (Technical Details)
- System architecture
- Component descriptions
- Data flow diagrams
- Network topology
- State management

### TESTING.md (Test Guide)
- 15 detailed test cases
- Validation procedures
- Performance benchmarks
- Troubleshooting

### DEPLOYMENT.md (Submission Guide)
- Pre-submission checklist
- Roll number updates
- Validation steps
- ZIP creation
- Evaluation process

### INDEX.md (This File)
- Documentation navigation
- Quick reference
- Command cheat sheet
- FAQ

## 🎯 Assignment Compliance

All assignment requirements are documented in:
- [PROJECT_SUMMARY.md - Requirements Met](PROJECT_SUMMARY.md#assignment-requirements-met)
- [DEPLOYMENT.md - Final Checklist](DEPLOYMENT.md#final-checklist-before-submission)

## 🔗 External Resources

- **Docker Documentation**: https://docs.docker.com/
- **Apache Kafka**: https://kafka.apache.org/documentation/
- **Apache Spark**: https://spark.apache.org/docs/latest/
- **PostgreSQL**: https://www.postgresql.org/docs/

## 📅 Version History

- **v1.0** (January 2025) - Initial release
  - Complete Docker-based implementation
  - Comprehensive documentation
  - 15 test cases
  - Helper scripts for Windows and Linux/Mac

---

## 🚀 Ready to Start?

1. **First time?** → [QUICKSTART.md](QUICKSTART.md)
2. **Want details?** → [README.md](README.md)
3. **Need to submit?** → [DEPLOYMENT.md](DEPLOYMENT.md)

---

**Happy Streaming! 🎉**

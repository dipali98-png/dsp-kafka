import sys
import yaml
from pyspark.sql import SparkSession
from pyspark.sql.functions import from_json, col, to_date
from pyspark.sql.types import StructType, StructField, IntegerType, StringType, DecimalType, TimestampType

def load_config(config_path):
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def main(config_path):
    config = load_config(config_path)
    
    spark = SparkSession.builder \
        .appName("OrdersStreamConsumer") \
        .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.1") \
        .config("spark.sql.streaming.checkpointLocation", config['streaming']['checkpoint_location']) \
        .getOrCreate()
    
    kafka_config = config['kafka']
    datalake_config = config['datalake']
    streaming_config = config['streaming']
    
    print(f"Starting Stream Consumer from topic: {kafka_config['topic']}")
    print(f"Writing to Data Lake: {datalake_config['path']}")
    
    schema = StructType([
        StructField("order_id", IntegerType(), True),
        StructField("customer_name", StringType(), True),
        StructField("restaurant_name", StringType(), True),
        StructField("item", StringType(), True),
        StructField("amount", DecimalType(10, 2), True),
        StructField("order_status", StringType(), True),
        StructField("created_at", TimestampType(), True)
    ])
    
    df = spark.readStream \
        .format("kafka") \
        .option("kafka.bootstrap.servers", kafka_config['brokers']) \
        .option("subscribe", kafka_config['topic']) \
        .option("startingOffsets", "earliest") \
        .load()
    
    parsed_df = df.select(
        from_json(col("value").cast("string"), schema).alias("data")
    ).select("data.*")
    
    cleaned_df = parsed_df \
        .filter(col("order_id").isNotNull()) \
        .filter(col("amount") > 0) \
        .withColumn("date", to_date(col("created_at")))
    
    query = cleaned_df.writeStream \
        .format(datalake_config['format']) \
        .outputMode("append") \
        .option("path", datalake_config['path']) \
        .option("checkpointLocation", streaming_config['checkpoint_location']) \
        .partitionBy("date") \
        .trigger(processingTime=f"{streaming_config['batch_interval']} seconds") \
        .start()
    
    print("Stream Consumer started successfully")
    print("Waiting for data...")
    
    query.awaitTermination()

if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] != '--config':
        print("Usage: spark-submit orders_stream_consumer.py --config <config_file>")
        sys.exit(1)
    
    config_path = sys.argv[2]
    main(config_path)

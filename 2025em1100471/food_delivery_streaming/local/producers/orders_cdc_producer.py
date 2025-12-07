import sys
import yaml
import json
import time
import os
from datetime import datetime
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_json, struct

def load_config(config_path):
    with open(config_path, 'r') as file:
        return yaml.safe_load(file)

def get_last_processed_timestamp(location):
    timestamp_file = os.path.join(location, 'last_timestamp.txt')
    os.makedirs(location, exist_ok=True)
    
    if os.path.exists(timestamp_file):
        with open(timestamp_file, 'r') as f:
            return f.read().strip()
    return '1970-01-01 00:00:00'

def save_last_processed_timestamp(location, timestamp):
    timestamp_file = os.path.join(location, 'last_timestamp.txt')
    os.makedirs(location, exist_ok=True)
    
    with open(timestamp_file, 'w') as f:
        f.write(str(timestamp))

def main(config_path):
    config = load_config(config_path)
    
    spark = SparkSession.builder \
        .appName("OrdersCDCProducer") \
        .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.1,org.postgresql:postgresql:42.6.0") \
        .getOrCreate()
    
    postgres_config = config['postgres']
    kafka_config = config['kafka']
    streaming_config = config['streaming']
    
    print(f"Starting CDC Producer for table: {postgres_config['table']}")
    print(f"Kafka topic: {kafka_config['topic']}")
    
    try:
        while True:
            last_timestamp = get_last_processed_timestamp(
                streaming_config['last_processed_timestamp_location']
            )
            
            print(f"\nPolling for records after: {last_timestamp}")
            
            query = f"""
                (SELECT order_id, customer_name, restaurant_name, item, amount, 
                        order_status, created_at 
                 FROM {postgres_config['table']} 
                 WHERE created_at > '{last_timestamp}'
                 ORDER BY created_at) AS new_orders
            """
            
            df = spark.read \
                .format("jdbc") \
                .option("url", postgres_config['jdbc_url']) \
                .option("dbtable", query) \
                .option("user", postgres_config['user']) \
                .option("password", postgres_config['password']) \
                .option("driver", "org.postgresql.Driver") \
                .load()
            
            if df.count() > 0:
                print(f"Found {df.count()} new records")
                
                df_json = df.selectExpr("to_json(struct(*)) AS value")
                
                df_json.write \
                    .format("kafka") \
                    .option("kafka.bootstrap.servers", kafka_config['brokers']) \
                    .option("topic", kafka_config['topic']) \
                    .save()
                
                max_timestamp = df.agg({"created_at": "max"}).collect()[0][0]
                save_last_processed_timestamp(
                    streaming_config['last_processed_timestamp_location'],
                    max_timestamp
                )
                
                print(f"Published {df.count()} records to Kafka")
                print(f"Updated last processed timestamp to: {max_timestamp}")
            else:
                print("No new records found")
            
            time.sleep(streaming_config['batch_interval'])
            
    except KeyboardInterrupt:
        print("\nStopping CDC Producer...")
    finally:
        spark.stop()

if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] != '--config':
        print("Usage: spark-submit orders_cdc_producer.py --config <config_file>")
        sys.exit(1)
    
    config_path = sys.argv[2]
    main(config_path)

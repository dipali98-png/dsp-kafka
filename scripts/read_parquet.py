from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("ReadParquet").getOrCreate()

df = spark.read.parquet("/opt/spark-apps/datalake/food/2025em1100471/output/orders/")
print(f"\nTotal records: {df.count()}")
print("\nData:")
df.show(truncate=False)
print("\nRecords by date:")
df.groupBy("date").count().show()

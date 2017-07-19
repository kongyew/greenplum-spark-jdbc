# Greenplum
The Greenplum Database (GPDB) is an advanced, fully featured, open source data warehouse. It provides powerful and rapid analytics on petabyte scale data volumes. Uniquely geared toward big data analytics, Greenplum Database is powered by the world’s most advanced cost-based query optimizer delivering high analytical query performance on large data volumes.

# Apache Spark

Spark is a fast and general cluster computing system for Big Data. It provides
high-level APIs in Scala, Java, Python, and R, and an optimized engine that
supports general computation graphs for data analysis. It also supports a
rich set of higher-level tools including Spark SQL for SQL and DataFrames,
MLlib for machine learning, GraphX for graph processing,
and Spark Streaming for stream processing.

<http://spark.apache.org/>

## Greenplum with Spark using JDBC
## Pre-requisites:
- [docker-compose](http://docs.docker.com/compose)


# Using docker-compose
To create a simplistic standalone cluster with the following command. It builds a docker image with Pivotal Greenplum binaries and download some existing images such as Spark master and worker.
```
    docker-compose up
```
The SparkUI will be running at `http://${YOUR_DOCKER_HOST}:8080` with one worker listed. To run `pyspark`, exec into a container:

    docker exec -it greenplumsparkjdbc_master_1 bin/bash
    bin/pyspark

To run `SparkPi`, exec into a container:

    docker exec -it greenplumsparkjdbc_master_1 /bin/bash
    bin/run-example SparkPi 10

##  How to connect to Greenplum with JDBC driver
In this example, we will describe how to configure JDBC driver when you run Spark-shell.

1. Connect to the Spark master docker image
```
$docker exec -it greenplumsparkjdbc_master_1 /bin/bash
```
2. Execute the command below to download jar into ~/.ivy2/jars directory and type "":quit" to exit the Spark shell
```
root@master:/usr/spark-2.1.0#bin/spark-shell --packages org.postgresql:postgresql:42.1.1
Ivy Default Cache set to: /root/.ivy2/cache
The jars for the packages stored in: /root/.ivy2/jars
:: loading settings :: url = jar:file:/usr/spark-2.1.0/jars/ivy-2.4.0.jar!/org/apache/ivy/core/settings/ivysettings.xml
org.postgresql#postgresql added as a dependency
:: resolving dependencies :: org.apache.spark#spark-submit-parent;1.0
	confs: [default]
	found org.postgresql#postgresql;42.1.1 in central
:: resolution report :: resolve 366ms :: artifacts dl 3ms
...
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.1.0
      /_/

Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_112)
Type in expressions to have them evaluated.
Type :help for more information.
scala>
```

3. By default,the driver file is located at ~/.ivy2/jars/. Next, you can run your Spark-shell to load this Postgresql driver.
```
bin/spark-shell --driver-class-path ~/.ivy2/jars/org.postgresql_postgresql-42.1.1.jar
...
scala>
```

4. Verify JDBC driver is successfully loaded by Spark Shell
You can follow the example below to verify the JDBC driver. The scala repl confirms the driver is accessible by show “res1” result.
```
scala> Class.forName("org.postgresql.Driver")
res1: Class[_] = class org.postgresql.Driver
```

## How read data from Greenplum into Spark
In this section, we will read data from Greenplum into Spark. It assumes the database and table are already created. See [how to setup GPDB DB with script](README_DB.md)

By default, you can run the command below to retrieve data from Greenplum with a single data partition in Spark cluster.
```
// that gives an one-partition Dataset
val opts = Map(
  "url" -> "jdbc:postgresql://greenplumspark_gpdb_1/basic_db?user=gpadmin&password=pivotal",
  "dbtable" -> "basicdb")
val df = spark.
  read.
  format("jdbc").
  options(opts).
  load
  ...
  opts: scala.collection.immutable.Map[String,String] = Map(url -> jdbc:postgresql://greenplumspark_gpdb_1/basic_db?user=gpadmin&password=pivotal, dbtable -> basicdb)
  df: org.apache.spark.sql.DataFrame = [id: int, value: string]
  ```

## license
Apache

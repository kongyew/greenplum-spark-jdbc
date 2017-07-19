# Greenplum
The Greenplum Database (GPDB) is an advanced, fully featured, open source data warehouse. It provides powerful and rapid analytics on petabyte scale data volumes. Uniquely geared toward big data analytics, Greenplum Database is powered by the world’s most advanced cost-based query optimizer delivering high analytical query performance on large data volumes.

<https://pivotal.io/pivotal-greenplum>

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
To create a simplistic standalone cluster with the following command in the github root directory.
It builds a docker image with Pivotal Greenplum binaries and download some existing images such as Spark master and worker.
```
    $ docker-compose up
```

    The SparkUI will be running at `http://${YOUR_DOCKER_HOST}:8080` with one worker listed. To run `pyspark`, exec into a container:
```
    $ docker exec -it greenplumsparkjdbc_master_1 bin/bash
    $ bin/pyspark
```
To run `SparkPi`, exec into a container:
```
    $ docker exec -it greenplumsparkjdbc_master_1 /bin/bash
    $ bin/run-example SparkPi 10
```

To access `Greenplum cluster`, exec into a container:
```
    $ docker exec -it greenplumsparkjdbc_master_1 bash
    root@master:/usr/spark-2.1.0#
```

##  How to connect to Greenplum with JDBC driver
In this example, we will describe how to configure JDBC driver when you run Spark-shell.

1. Connect to the Spark master docker image
```
$docker exec -it greenplumsparkjdbc_master_1 /bin/bash
```
2. Execute the command below to download jar into `~/.ivy2/jars` directory and type `:quit` to exit the Spark shell
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
root@master:/usr/spark-2.1.0# bin/spark-shell --driver-class-path ~/.ivy2/jars/org.postgresql_postgresql-42.1.1.jar  --jars ~/.ivy2/jars/org.postgresql_postgresql-42.1.1.jar
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

4. Verify JDBC driver is successfully loaded by Spark Shell
You can follow the example below to verify the JDBC driver. The scala repl confirms the driver is accessible by returning `res1` result.
```
scala> Class.forName("org.postgresql.Driver")
res1: Class[_] = class org.postgresql.Driver
```

## How read data from Greenplum into Spark
In this section, we will read data from Greenplum into Spark. It assumes the database and table are already created. See [how to setup GPDB DB with script](README_DB.md)

By default, you can run the command below to retrieve data from Greenplum with a single data partition in Spark cluster. In order to paste the command, you need to type `:paste` in the scala environment and paste the code below, followed by `Ctrl-D`
```
scala> :paste
// Entering paste mode (ctrl-D to finish)
// that gives an one-partition Dataset
val opts = Map(
  "url" -> "jdbc:postgresql://greenplumsparkjdbc_gpdb_1/basic_db?user=gpadmin&password=pivotal",
  "dbtable" -> "basictable")
val df = spark.
  read.
  format("jdbc").
  options(opts).
  load

  // Exiting paste mode, now interpreting.

opts: scala.collection.immutable.Map[String,String] = Map(url -> jdbc:postgresql://greenplumsparkjdbc_gpdb_1/basic_db?user=gpadmin&password=pivotal, dbtable -> basictable)
df: org.apache.spark.sql.DataFrame = [id: int, value: string]
```

You can verify the Spark DataFrame by running these commands `df.printSchema` and `df.show()`
```
scala> df.printSchema
root
 |-- id: integer (nullable = false)
 |-- value: string (nullable = true)
scala> df.show()
+---+--------+
| id|   value|
+---+--------+
|  1|   Alice|
|  3| Charlie|
|  5|     Jim|
|  7|    Jack|
|  9|     Zim|
| 15|     Jim|
| 11|     Bob|
| 13|     Eve|
| 17|Victoria|
| 25|Victoria|
| 27|   Alice|
| 29| Charlie|
| 31|     Zim|
| 19|   Alice|
| 21| Charlie|
| 23|     Jim|
| 33|     Jim|
| 35|     Eve|
| 43|Victoria|
| 45|   Alice|
+---+--------+
only showing top 20 rows

scala> df.filter(df("id") > 40).show()
+---+--------+
| id|   value|
+---+--------+
| 43|Victoria|
| 45|   Alice|
| 47|    Jack|
| 49|     Bob|
| 51|    John|
| 53|    Jack|
| 55|     Zim|
| 57|Victoria|
| 41|     Jim|
| 59|     Zim|
| 61|     Bob|
| 63|Victoria|
| 65|   Alice|
| 67|     Zim|
| 69| Charlie|
| 71|     Jim|
| 95|     Bob|
| 97|     Eve|
| 99|Victoria|
|101|   Alice|
+---+--------+
only showing top 20 rows

scala> df.explain
== Physical Plan ==
*Scan JDBCRelation(basictable) [numPartitions=1] [id#0,value#1] ReadSchema: struct<id:int,value:string>
```

## How to write data from Spark DataFrame into Greenplum
In this section, you can write data from Spark DataFrame into Greenplum table.

1. Determine the number of records in the "basictable" table.  
```
$ docker exec -it greenplumsparkjdbc_gpdb_1 /bin/bash
[root@d632f535db87 data]# psql -h localhost -U gpadmin -d basic_db -c "select count(*) from basictable" -w pivotal
psql: warning: extra command-line argument "pivotal" ignored
 count
-------
18432
(1 row)
```
2. Configure JDBC URL and connection Properties and use DataFrame write operation to write data from Spark into Greenplum.
```
scala> :paste
// Entering paste mode (ctrl-D to finish)

val jdbcUrl = s"jdbc:postgresql://greenplumsparkjdbc_gpdb_1/basic_db?user=gpadmin&password=pivotal"
val connectionProperties = new java.util.Properties()
df.write.mode("Append") .jdbc( url = jdbcUrl, table = "basictable", connectionProperties = connectionProperties)

// Exiting paste mode, now interpreting.
jdbcUrl: String = jdbc:postgresql://greenplumsparkjdbc_gpdb_1/basic_db?user=gpadmin&password=pivotal
connectionProperties: java.util.Properties = {}
```
3. Verify the write operation is successful by exec into GPDB container and run psql command-line. The total number records in the Greenplum table must be 2x of the original data.
```
$ docker exec -it greenplumsparkjdbc_gpdb_1 /bin/bash
[root@d632f535db87 data]# psql -h localhost -U gpadmin -d basic_db -c "select count(*) from basictable" -w pivotal
psql: warning: extra command-line argument "pivotal" ignored
 count
-------
73728
(1 row)
```

4. Next, you can write DataFrame data into an new Greenplum table.
```
scala>df.write.mode("Append") .jdbc( url = jdbcUrl, table = "NEWTable", connectionProperties = connectionProperties)
```
updateDF.write.mode("Append") .jdbc( url = jdbcUrl, table = "NEWTable", connectionProperties = connectionProperties)


5. Run psql commands to verify the new table with new records.
```
[root@d632f535db87 scripts]# psql -h localhost -U gpadmin -d basic_db -c "\dt" -
psql: warning: extra command-line argument "pivotal" ignored
            List of relations
 Schema |     Name      | Type  |  Owner
--------+---------------+-------+---------
 public | basictable    | table | gpadmin
 public | basictablenew | table | gpadmin
 public | newtable      | table | gpadmin
(3 rows)

[root@d632f535db87 data]# psql -h localhost -U gpadmin -d basic_db -c "select count(*) from newtable" -w pivotal
psql: warning: extra command-line argument "pivotal" ignored
 count
-------
18432
(1 row)
```


## Conclusions
In summary, Greenplum works seamlessly with Apache Spark by using Postgresql JDBC driver. Apache Spark provides parallel data transfer to Greenplum via JDBC driver and this data transfer process works between Greenplum master host and Spark workers. Thus, the performance constraints are limited as it is not using the high speed data transfer features provided by Greenplum gpfdist protocol





## License
Apache

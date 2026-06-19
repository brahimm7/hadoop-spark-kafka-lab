[![Docker Pulls](https://img.shields.io/docker/pulls/brahimm11/bigdata-cluster?style=flat-for-the-badge&logo=docker)](https://hub.docker.com/r/brahimm11/bigdata-cluster)

> **🚀 Pre-built Container Image Available:** The fully configured, optimized cluster base image for this lab environment is published and publicly available on Docker Hub at [brahimm11/bigdata-cluster:1.0](https://hub.docker.com/r/brahimm11/bigdata-cluster).

### ⚡ Quick Image Pull
To pull the compiled image directly from the registry without building the Dockerfile manually:
```bash
docker pull brahimm11/bigdata-cluster:1.0

# Distributed Multi-Node Big Data Cluster (Hadoop 3.4.3 / Spark 3.5.1 / Kafka 3.7.0)

This repository contains the complete infrastructure orchestration code to deploy a fully functional, multi-node Big Data cluster environment using Docker. The architecture splits workloads across a dedicated coordinator Master node and two independent Worker/Slave nodes, utilizing secure internal SSH keys for automated cross-daemon communication.

---

## 📦 Core Architecture & Software Stack

The cluster is built on an **Ubuntu 24.04 LTS** base image, running stable and mutually compatible versions of the enterprise data engineering ecosystem:

* **Java Runtime:** OpenJDK 11 (Optimized for Hadoop 3 execution frameworks)
* **Distributed Storage:** Apache Hadoop 3.4.3 (HDFS distributed storage & YARN resource allocation)
* **Stream Ingestion:** Apache Kafka 3.7.0 (Managed via integrated Apache ZooKeeper)
* **Unified Analytics:** Apache Spark 3.5.1 (Pre-built for Hadoop 3 architectures, featuring interactive Scala `spark-shell` execution)
* **Windows Compatibility:** Integrated `dos2unix` automation layer to seamlessly eliminate Windows line ending (`\r`) script runtime breaks during container initialization.

---

## 🗺️ Network Topography & Port Allocation

The cluster provisions an isolated virtual bridge network (`172.98.0.0/16`) assigning static internal IP addresses to ensure persistent daemon discovery. All primary administrative web dashboards are mapped directly to the host machine via `localhost`.

| Container Name | Role | Fixed Internal IP | Exposed Host Web Interface UI / Port |
| --- | --- | --- | --- |
| **`hadoop-master`** | NameNode / YARN ResourceManager / Spark Master / Kafka Broker | `172.98.0.2` | • **HDFS NameNode UI:** [http://localhost:9870](http://localhost:9870)<br>• **YARN Cluster UI:** [http://localhost:8088](http://localhost:8088)<br>• **Spark Master UI:** [http://localhost:8080](http://localhost:8080)<br>• **Kafka Ingestion Port:** `9092` |
| **`hadoop-slave1`** | Compute Worker / Data Storage Node 1 | `172.98.0.3` | • **Spark Worker 1 UI:** [http://localhost:8081](http://localhost:8081) |
| **`hadoop-slave2`** | Compute Worker / Data Storage Node 2 | `172.98.0.4` | • **Spark Worker 2 UI:** [http://localhost:8082](http://localhost:8082) |

---

## 🚀 Cluster Orchestration Lifecycle

### 1. Provision the Multi-Node Infrastructure

From your host machine's terminal, navigate to the project root directory and spin up the containers in detached mode:

```bash
docker-compose up -d
```

Verify that all virtual nodes are executing stably:

```bash
docker ps
```

### 2. Connect to the Master Node Workspace

Access the secure terminal instance of the primary cluster coordinator:

```bash
docker exec -it hadoop-master bash
```

### 3. Initialize Distributed Storage & Cluster Compute

Execute the pre-packaged bootstrapper script to automatically convert line endings, handle security keys, format empty HDFS NameNodes, and boot the storage layers:

```bash
./start-hadoop.sh
```

Next, boot the cluster processing runtime and attach the compute worker engines running inside the slave containers:

```bash
$SPARK_HOME/sbin/start-master.sh
ssh hadoop-slave1 $SPARK_HOME/sbin/start-worker.sh spark://hadoop-master:7077
ssh hadoop-slave2 $SPARK_HOME/sbin/start-worker.sh spark://hadoop-master:7077
```

### 4. Activate the Real-Time Event Streaming Platform

Fire up the messaging queues and coordination logs in the correct sequence using the custom utility script:

```bash
./start-kafka-zookeeper.sh
```

### 5. Verify Active Daemons

Run the Java Process Status Tool inside the master container shell to confirm systemic health:

```bash
jps
```

**Expected Output Matrix on Master:**

* `NameNode` / `SecondaryNameNode` (HDFS Storage Coordination)
* `ResourceManager` (YARN Workload Orchestration)
* `Master` (Spark Resource Master)
* `QuorumPeerMain` / `Kafka` (Stable Event Streaming Broker)

To ensure the worker daemons are correctly up and executing on the slaves, check via SSH:

```bash
ssh root@hadoop-slave1 "jps"
```

*Expected on Slaves: `DataNode`, `NodeManager`, and Spark `Worker`.*

---

## 📖 Complete Pipeline Tutorial: From Ingestion to Processing

Follow this step-by-step tutorial to ingest transactional streams through Kafka, persist them into HDFS storage, and process them using Spark Scala DataFrames.

### Step 1: Create Kafka Core Topics

Because this environment runs **Kafka 3.7.0**, administrative commands point directly to the broker instead of legacy ZooKeeper instances. Create your processing topics:

```bash
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic topic_clients
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic topic_produits
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic topic_commandes
kafka-topics.sh --create --bootstrap-server localhost:9092 --replication-factor 1 --partitions 1 --topic topic_paiements
```

Verify that all topics are successfully registered:

```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

### Step 2: Stream Live Data into the Cluster

Open an interactive real-time producer session to send JSON records into `topic_clients`:

```bash
kafka-console-producer.sh --bootstrap-server localhost:9092 --topic topic_clients
```

When the `>` prompt appears, paste your dataset lines and press Enter:

```json
{"id_client": 101, "nom": "Brahim", "ville": "Casablanca"}
{"id_client": 102, "nom": "Hamza", "ville": "Rabat"}
```

Press `Ctrl + C` when you are done typing to exit the producer mode cleanly.

### Step 3: Archive Streaming Real-Time Logs into HDFS

Kafka data exists in volatile logs. To save it permanently into your data lake for batch processing, consume from the topic down to your local container storage, then transfer it into HDFS:

```bash
# Consume the messages into a temporary local JSON log
kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic topic_clients --from-beginning --timeout-ms 10000 > /root/clients_kafka.json

# Establish directories and upload the data to HDFS storage
hdfs dfs -mkdir -p /kafka_data/clients
hdfs dfs -put -f /root/clients_kafka.json /kafka_data/clients/

# Verify the file is in HDFS
hdfs dfs -ls /kafka_data/clients/
```

### Step 4: Extract and Process using the Spark Shell

With your data safely in HDFS, spin up the interactive distributed Spark SQL platform:

```bash
spark-shell --master spark://hadoop-master:7077
```

Once the interactive Scala prompt loads (`scala>`), paste the following code to construct an optimized Spark DataFrame, infer schemas automatically, and view your records:

```scala
// Load JSON dataset out of the HDFS cluster storage layer
val clientsDF = spark.read.json("hdfs://hadoop-master:9000/kafka_data/clients/clients_kafka.json")

// Print structural schema mappings
clientsDF.printSchema()

// Display data rows
clientsDF.show()

// Register as a temporary SQL view to run relational queries
clientsDF.createOrReplaceTempView("clients_view")
spark.sql("SELECT nom FROM clients_view WHERE ville = 'Casablanca'").show()
```

To leave the processing environment and return to the primary container terminal prompt, type:

```scala
:quit
```

---

## 🧹 Infrastructure Teardown

To safely stop your infrastructure, flush out temporary runtime logs, and free up host computer RAM resources, exit the container terminal and execute:

```bash
docker-compose down -v
```

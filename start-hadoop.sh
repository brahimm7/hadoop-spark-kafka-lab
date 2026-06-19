#!/bin/bash
echo "Starting Hadoop 3.4.3 services (HDFS & YARN)..."

# Clean Windows text formats (\r) on all nodes before launching
dos2unix $HADOOP_HOME/etc/hadoop/hadoop-env.sh
ssh root@hadoop-slave1 "dos2unix $HADOOP_HOME/etc/hadoop/hadoop-env.sh"
ssh root@hadoop-slave2 "dos2unix $HADOOP_HOME/etc/hadoop/hadoop-env.sh"

# Format the NameNode automatically if it is empty
if [ ! -d "/usr/local/hadoop/hadoop_data/hdfs/namenode/current" ]; then
    echo "Initializing (Formatting) the HDFS NameNode..."
    $HADOOP_HOME/bin/hdfs namenode -format -force
fi

# Launch Hadoop daemons
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
echo "✓ Hadoop (HDFS & YARN) started successfully!"
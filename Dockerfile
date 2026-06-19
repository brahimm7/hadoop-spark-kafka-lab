FROM ubuntu:24.04
LABEL maintainer="Brahim"

ENV DEBIAN_FRONTEND=noninteractive

# 1. Install Java 11, Python3, and base utilities
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk wget openssh-server vim sudo curl tar dos2unix python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Global Environment Variables
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV SPARK_HOME=/usr/local/spark
ENV KAFKA_HOME=/usr/local/kafka

ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$KAFKA_HOME/bin

# 2. Download Hadoop 3.4.3
RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.4.3/hadoop-3.4.3.tar.gz && \
    tar -xzvf hadoop-3.4.3.tar.gz && \
    mv hadoop-3.4.3 $HADOOP_HOME && \
    rm hadoop-3.4.3.tar.gz

# 3. Download Spark 3.5.1
RUN wget https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz && \
    tar -xzvf spark-3.5.1-bin-hadoop3.tgz && \
    mv spark-3.5.1-bin-hadoop3 $SPARK_HOME && \
    rm spark-3.5.1-bin-hadoop3.tgz

# 4. Download Kafka 3.7.0
RUN wget https://archive.apache.org/dist/kafka/3.7.0/kafka_2.13-3.7.0.tgz && \
    tar -xzvf kafka_2.13-3.7.0.tgz && \
    mv kafka_2.13-3.7.0 $KAFKA_HOME && \
    rm kafka_2.13-3.7.0.tgz

# 5. SSH Configuration
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

# 6. Copy configuration files
COPY config/* /tmp/
RUN dos2unix /tmp/* && \
    mv /tmp/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/workers $HADOOP_HOME/etc/hadoop/workers

# 7. Copy manual scripts to the root of the container
COPY start-hadoop.sh /
COPY start-kafka-zookeeper.sh /
RUN dos2unix /start-hadoop.sh /start-kafka-zookeeper.sh && \
    chmod +x /start-hadoop.sh /start-kafka-zookeeper.sh

EXPOSE 9870 8088 9000 8080 7077 9092 2181

# SSH runs in the background, leaving the container available for your commands
CMD ["service", "ssh", "start", "-D"]
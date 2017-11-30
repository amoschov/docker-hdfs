FROM mlaccetti/docker-oracle-java8-ubuntu-16.04
MAINTAINER amoshcov

ENV DEBIAN_FRONTEND noninteractive

ARG HADOOP_VERSION=2.9.0
LABEL Description="Hadoop Dev", "Hadoop Version"="$HADOOP_VERSION"

# Refresh package lists
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get -y upgrade
RUN apt-get install -qy rsync curl openssh-server openssh-client vim nfs-common net-tools less vim mc

RUN mkdir -p /data/hdfs-nfs/
RUN mkdir -p /opt
WORKDIR /opt

# Install Hadoop

RUN curl -L http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz -s -o - | tar -xzf -
RUN mv hadoop-$HADOOP_VERSION hadoop

# Setup
WORKDIR /opt/hadoop
ENV PATH /opt/hadoop/bin:/opt/hadoop/sbin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN sed --in-place='.ori' -e "s/\${JAVA_HOME}/\/usr\/lib\/jvm\/java-8-oracle/" etc/hadoop/hadoop-env.sh

# Configure ssh client
RUN ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa && \
    cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

RUN echo "\nHost *\n" >> ~/.ssh/config && \
    echo "   StrictHostKeyChecking no\n" >> ~/.ssh/config && \
    echo "   UserKnownHostsFile=/dev/null\n" >> ~/.ssh/config


# Disable sshd authentication
RUN echo "root:root" | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Pseudo-Distributed Operation
COPY etc/hadoop/core-site.xml etc/hadoop/core-site.xml
COPY etc/hadoop/hdfs-site.xml etc/hadoop/hdfs-site.xml
RUN hdfs namenode -format

ADD entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh

# SSH
EXPOSE 22
# hdfs://localhost:8020
EXPOSE 8020
# HDFS namenode
EXPOSE 50020
# HDFS Web browser
EXPOSE 50070
# HDFS datanodes
EXPOSE 50075
# HDFS secondary namenode
EXPOSE 50090

CMD ["/entrypoint.sh", "-d"]

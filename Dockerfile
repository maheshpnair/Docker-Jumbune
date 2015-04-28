#
# Dockerfile - Jumbune
#
FROM     ubuntu:12.04
MAINTAINER Mahesh Nair <maheshp.nair@impetus.co.in>

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Upgradation and installation of required packages.
RUN apt-get update && apt-get install -y curl supervisor openssh-server net-tools iputils-ping nano zip

# Installing JDK and adding JAVA HOME
ENV JDK_URL http://download.oracle.com/otn-pub/java/jdk
ENV JDK_VER 7u79-b15
ENV JDK_VER2 jdk-7u79
ENV JAVA_HOME /usr/local/jdk
ENV PATH $PATH:$JAVA_HOME/bin
RUN cd $SRC_DIR && curl -LO "$JDK_URL/$JDK_VER/$JDK_VER2-linux-x64.tar.gz" -H 'Cookie: oraclelicense=accept-securebackup-cookie' \
 && tar xzf $JDK_VER2-linux-x64.tar.gz && mv jdk1* $JAVA_HOME && rm -f $JDK_VER2-linux-x64.tar.gz \
 && echo '' >> /etc/profile \
 && echo '# JDK' >> /etc/profile \
 && echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile \
 && echo 'export PATH="$PATH:$JAVA_HOME/bin"' >> /etc/profile \
 && echo '' >> /etc/profile
#Fetch Apache Hadoop and untar
ENV SRC_DIR /opt
ENV HADOOP_URL https://archive.apache.org/dist/hadoop/core/
ENV HADOOP_VERSION hadoop-2.4.1
RUN cd $SRC_DIR &&  wget --no-check-certificate "$HADOOP_URL/$HADOOP_VERSION/$HADOOP_VERSION.tar.gz" \
 && tar xzf $HADOOP_VERSION.tar.gz ; rm -f $HADOOP_VERSION.tar.gz

# Addind required env variables to /etc/profile
ENV HADOOP_PREFIX $SRC_DIR/$HADOOP_VERSION
ENV HADOOP_HOME $HADOOP_PREFIX
ENV PATH $PATH:$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_PREFIX
ENV HADOOP_COMMON_HOME $HADOOP_PREFIX
ENV HADOOP_HDFS_HOME $HADOOP_PREFIX
ENV YARN_HOME $HADOOP_PREFIX
RUN echo '# Hadoop' >> /etc/profile \
 && echo "export HADOOP_PREFIX=$HADOOP_PREFIX" >> /etc/profile \
 && echo 'export HADOOP_HOME=$HADOOP_PREFIX' >> /etc/profile \
 && echo 'export PATH=$PATH:$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin' >> /etc/profile \
 && echo 'export HADOOP_MAPRED_HOME=$HADOOP_PREFIX' >> /etc/profile \
 && echo 'export HADOOP_COMMON_HOME=$HADOOP_PREFIX' >> /etc/profile \
 && echo 'export HADOOP_HDFS_HOME=$HADOOP_PREFIX' >> /etc/profile \
 && echo 'export YARN_HOME=$HADOOP_PREFIX' >> /etc/profile 
# adding configurations 
ADD https://raw.githubusercontent.com/maheshpnair/docker-hadoop/master/conf/core-site.xml $HADOOP_PREFIX/etc/hadoop/core-site.xml
ADD https://raw.githubusercontent.com/maheshpnair/docker-hadoop/master/conf/hdfs-site.xml $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
ADD https://raw.githubusercontent.com/maheshpnair/docker-hadoop/master/conf/yarn-site.xml $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
ADD https://raw.githubusercontent.com/maheshpnair/docker-hadoop/master/conf/mapred-site.xml $HADOOP_PREFIX/etc/hadoop/mapred-site.xml

# writing the appropriate values to the hadoop configuration files
#RUN echo "<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>fs.default.name</name><value>hdfs://localhost:9000</value><final>true</final></property></configuration>" >> $HADOOP_PREFIX/etc/hadoop/core-site.xml
#RUN echo "<?xml version="1.0" encoding="UTF-8"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>dfs.namenode.name.dir</name><value>file:/hdfs/dfs/name</value><final>true</final></property><property><name>dfs.datanode.data.dir</name><value>file:/hdfs/dfs/data</value><final>true</final></property><property><name>dfs.permissions</name><value>false</value></property></configuration>" >> $HADOOP_PREFIX/etc/hadoop/hdfs-site.xml
#RUN echo "<?xml version="1.0"?><?xml-stylesheet type="text/xsl" href="configuration.xsl"?><configuration><property><name>mapreduce.framework.name</name><value>yarn</value></property><property><name>mapred.system.dir</name><value>file:/hdfs/mapred/system</value><final>true</final></property><property><name>mapred.local.dir</name><value>file:/hdfs/mapred/local</value><final>true</final></property><property><name>mapreduce.map.memory.mb</name><value>1024</value></property><property><name>mapreduce.reduce.memory.mb</name><value>2048</value></property></configuration>" >> $HADOOP_PREFIX/etc/hadoop/mapred-site.xml
#RUN echo "<?xml version="1.0"?><configuration><property><name>yarn.nodemanager.aux-services</name><value>mapreduce_shuffle</value></property><property><name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name><value>org.apache.hadoop.mapred.ShuffleHandler</value></property><property><name>yarn.nodemanager.vmem-check-enabled </name><value>false</value></property></configuration>" >> $HADOOP_PREFIX/etc/hadoop/yarn-site.xml
RUN sed -i '/^export JAVA_HOME/ s:.*:export JAVA_HOME=/usr/local/jdk:' $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN echo 'export HADOOP_NAMENODE_OPTS="-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5677"' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN echo 'export HADOOP_DATANODE_OPTS="-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5679"' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh
RUN echo 'export YARN_NODEMANAGER_OPTS="-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5678"' >> $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
RUN echo 'export YARN_RESOURCEMANAGER_OPTS="-Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5680"'>> $HADOOP_PREFIX/etc/hadoop/yarn-env.sh

# Native
# https://gist.github.com/ruo91/7154697#comment-936487
RUN echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_PREFIX/lib/native' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh \
 && echo 'export HADOOP_OPTS=-Djava.library.path=$HADOOP_PREFIX/lib' >> $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh \
 && echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_PREFIX/lib/native' >> $HADOOP_PREFIX/etc/hadoop/yarn-env.sh \
 && echo 'export HADOOP_OPTS=-Djava.library.path=$HADOOP_PREFIX/lib' >> $HADOOP_PREFIX/etc/hadoop/yarn-env.sh
# SSH keygen
RUN cd /root && ssh-keygen -t dsa -P '' -f "/root/.ssh/id_dsa" \
 && cat /root/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys && chmod 644 /root/.ssh/authorized_keys

# Name node foramt
RUN $HADOOP_PREFIX/bin/hdfs namenode -format

# Supervisor
RUN mkdir -p /var/log/supervisor
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# SSH
#RUN nohup /usr/sbin/sshd 2>&1 &
RUN mkdir /var/run/sshd
RUN sed -i 's/without-password/yes/g' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN echo 'SSHD: ALL' >> /etc/hosts.allow
RUN echo "NoHostAuthenticationForLocalhost yes" >>~/.ssh/config
RUN echo "StrictHostKeyChecking no" >>~/.ssh/config

#Adding the ENV variables to /etc/profile
ENV JUMBUNE_HOME /root/jumbune
ENV AGENT_HOME /root/agent
RUN mkdir $JUMBUNE_HOME
RUN mkdir $AGENT_HOME
RUN echo '# Jumbune' >> /etc/profile \
 && echo "export JUMBUNE_HOME=$JUMBUNE_HOME" >> /etc/profile \
 && echo "export AGENT_HOME=$AGENT_HOME" >> /etc/profile
RUN cat /etc/profile

#fetching data

ADD http://www.textfiles.com/100/basicom5.phk /root/data

#etching Jumbune jar and the depoy script
RUN wget -O /root/jumbune-dist-1.4.1-bin.jar  http://www.jumbune.org/jar/beta/jumbune-dist-1.4.1-bin.jar
#ADD jumbune-dist-1.4.1-bin.jar /root/jumbune-dist-1.4.1-bin.jar
ADD conf/deploynRun.sh /root/deploynRun.sh
ADD conf/sampleJson.json /root/sampleJson.json
RUN chmod +x /root/deploynRun.sh
ADD conf/cluster-configuration.properties /root/agent/cluster-configuration.properties

#setting the username and password
RUN echo 'root:hadoop' |chpasswd
EXPOSE 22 8042 8088 50070 50075 50090 8088 5555 9999

#House keeping
RUN rm /opt/$HADOOP_VERSION/bin/hadoop.cmd

# Daemon
CMD ["/usr/bin/supervisord"]


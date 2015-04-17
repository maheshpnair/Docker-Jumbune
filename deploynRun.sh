#!/bin/bash
#This script deploys Jumbune, starts agent and jumbune container


java -jar /root/jumbune-dist-1.4.1-bin.jar -Ddistribution=a -DnamenodeIP=127.0.0.1 -Dusername=root -Dpassword=8InTHtRmX0dFyfI26mKX3Q==
nohup $JUMBUNE_HOME/bin/startWeb >/dev/null 2>&1 &
sleep 5
cd $JUMBUNE_HOME/agent-distribution/
nohup java -jar jumbune-remoting-1.4.1-agent.jar 5555 -verbose >/dev/null 2>&1 &
sleep 5
$HADOOP_HOME/bin/hadoop fs -put /root/data /data
sleep 5

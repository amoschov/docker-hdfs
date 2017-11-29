#!/usr/bin/env bash

ssh-keygen -t rsa -b 1024 -f /root/.ssh/id_rsa -N ""
cp -v /root/.ssh/{id_rsa.pub,authorized_keys}
chmod -v 0400 /root/.ssh/authorized_keys

service ssh start
start-dfs.sh
hadoop-daemon.sh start portmap
hadoop-daemon.sh start nfs3

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

if [[ $1 == "-d" ]]; then
  tail -f /dev/null /opt/hadoop/logs/*
fi


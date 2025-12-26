#!/bin/bash

servers=`sudo netstat -ntlp | grep 29095 | sort | awk '{print $NF}' | awk -F'/' '{print $1}'`
for i in $servers
do
        echo $i
        sudo kill -9 $i
done

./skynet/skynet etc/config.qiuqiu > qiuqiu.log  &
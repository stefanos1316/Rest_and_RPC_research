#!/bin/bash


./../../../apache-tomcat-9.0.8/bin/catalina.sh start
child=$!

echo ${child}

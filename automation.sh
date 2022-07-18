#!/bin/bash

#Update package index
sudo apt update -y

#Define S3 bucket name as variable
s3_bucket='upgrad-sangram'

#Get time stamp for log archive
timestamp=$(date '+%d%m%Y-%H%M%S')

myname="Sangram"

#Check is Apache2 is installed and Running
c2=`dpkg --get-selections | grep apache`
if [[ $? > 0 ]]
then
  sudo apt install apache2
fi
c1=`ps -eaf | grep -i apache2 |sed '/^$/d' | wc -l`
if [[ $c1 > 1 ]]
then
  echo "apache2 is installed and running"
else
  sudo systemctl restart apache2
fi

#Create tar compressed files of Apache2 Logs
tar -czvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log 

# Copy tar file to S3
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar



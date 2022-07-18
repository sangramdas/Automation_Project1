#!/bin/bash

#Update package index
sudo apt update -y

#Define S3 bucket name as variable
s3_bucket='upgrad-sangram'

#Get time stamp for log archive
timestamp=$(date '+%d%m%Y-%H%M%S')

myname="Sangram"

#Define variable for File of Log Metadata
FILE="/var/www/html/inventory.html"

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

#Copy tar file to S3
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

#Create Inventoory file
logfile=`ls -ltrh /tmp/*$timestamp*`
var1=`echo $logfile | cut -f5 -d' '`
var2=`echo $logfile | cut -f9 -d' ' | cut -f3 -d'/'`
var3=`echo $logfile | cut -f9 -d' ' | cut -f3 -d'/' | cut   -f2 -d'-'`
var4=`echo $logfile | cut -f9 -d' ' | cut -f3 -d'/' | cut   -f3 -d'-'`
var5=`echo $logfile | cut -f9 -d' ' | cut -f3 -d'/' | cut -f2 -d'.'`
if test -f "$FILE"
then
    echo -e "$var3-$var4\t$timestamp\t$var5\t$var1" >> $FILE
else
    echo -e "Log Type\tDate Created\tType\tSize" > $FILE
    echo -e "$var3-$var4\t$timestamp\t$var5\t$var1" >> $FILE

fi

#Create cronjob if it does not exists
CRON='/etc/cron.d/automation'
if test -f "$CRON"
then
    echo "cron exists"
else
    touch $CRON
    echo "SHELL=/bin/bash" > $CRON
    echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >> $CRON
    echo "0 17 * * * root /root/Automation_Project/automation.sh" >> $CRON
fi






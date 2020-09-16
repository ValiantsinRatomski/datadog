#!/bin/bash

sudo su

setenforce 0
systemctl stop firewalld

yum install httpd -y
systemctl start httpd
systemctl enable httpd

yum install tomcat tomcat-webapps tomcat-admin-webapps -y
systemctl start tomcat
systemctl enable tomcat

chmod 777 /var/log/tomcat
sleep 10
chmod 777 /var/log/tomcat/*

#-----------------------------------
#		AGENT 
#-----------------------------------

DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${api_key} DD_SITE="datadoghq.eu" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

sed -i 's/My first service/${ext_ip}/' /etc/datadog-agent/conf.d/http_check.d/conf.yaml.example
sed -i 's@http://some.url.example.com@http://${ext_ip}:8080@' /etc/datadog-agent/conf.d/http_check.d/conf.yaml.example
mv /etc/datadog-agent/conf.d/http_check.d/conf.yaml.example /etc/datadog-agent/conf.d/http_check.d/conf.yaml

mkdir /etc/datadog-agent/conf.d/log.d/
chown dd-agent: /etc/datadog-agent/conf.d/log.d/
cat > /etc/datadog-agent/conf.d/log.d/conf.yaml <<EOF
#Log section
logs:
  - type: file
    path: /var/log/tomcat/*.log
    service: tomcat
    source: myapp
EOF

chown dd-agent: /etc/datadog-agent/conf.d/log.d/*

echo 'logs_enabled: true' >> /etc/datadog-agent/datadog.yaml

systemctl restart datadog-agent
systemctl restart tomcat
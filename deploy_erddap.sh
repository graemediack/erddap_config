#!/bin/bash
#Gather variables
#set SCRIPT_HOME to location of this script
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#user defined variables for editing setup.xml, tomcat-users.xml
echo "Enter a new password for tomcat-users.xml:"
read
sed -i 's/updatePassword/$REPLY/g' $SCRIPT_HOME/files/tomcat-users.xml
echo "Enter device hostname/IP that will be used in the URL:"
read
sed -i 's/updateHostname/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your email address:"
read
sed -i 's/updateEmail/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your name:"
read
sed -i 's/updateName/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your company:"
read
sed -i 's/updateCompany/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your website"
read
sed -i 's/updateWebsite/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your telephone:"
read
sed -i 's/updateTelephone/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your address line 1:"
read
sed -i 's/updateAddressLine1/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your town:"
read
sed -i 's/updateTown/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your State or Province:"
read
sed -i 's/updateStateProvince/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your postcode:"
read
sed -i 's/updatePostcode/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter your country:"
read
sed -i 's/updateCountry/$REPLY/g' $SCRIPT_HOME/files/setup.xml
echo "Enter a short quotation you like:"
sed -i 's/updateQuote/$REPLY/g' $SCRIPT_HOME/files/setup.xml
#install JDK
apt install openjdk-8-jdk
#install unzip
apt install unzip
###
#Download files (note: tmp dir will clear out on reboots, optionally download to homedir and add step to delete at the end)
cd /tmp
wget https://www.mirrorservice.org/sites/ftp.apache.org/tomcat/tomcat-8/v8.5.53/bin/apache-tomcat-8.5.53.tar.gz
wget https://github.com/BobSimons/erddap/releases/download/v2.02/erddapContent.zip
wget https://github.com/BobSimons/erddap/releases/download/v2.02/erddap.war
###
read -n 1 -s -r -p "install and configure tomcat..."
###
#Install and configure Tomcat
#create tomcat group and user
groupadd tomcat
useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
#download tomcat
#create tomcat home directory
mkdir /opt/tomcat
#unpack tomcat files to tomcat home directory
tar xzvf /tmp/apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1
#modify ACLS (file permissions) of tomcat directory structure
chgrp -R tomcat /opt/tomcat
chmod -R g+r /opt/tomcat/conf
chmod g+x /opt/tomcat/conf
chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
#create systemd service file (pull from github repo)
cp $SCRIPT_HOME/files/tomcat.service /etc/systemd/system/tomcat.service
#May require editing of JAVA_HOME and Memory Allocation
#JAVA_HOME = sudo update-java-alternatives -l
#sudo nano /etc/systemd/system/tomcat.service
systemctl daemon-reload
#systemctl start tomcat
#systemctl status tomcat
#test tomcat welcome page http://<hostname>:8080
#Possible firewall adjustments required
#sudo ufw allow 8080
#sudo ufw allow 22
#sudo ufw enable
#enable service start on boot
systemctl enable tomcat
#configure tomcat user for management interfaces
#copy files from git repo
cp $SCRIPT_HOME/files/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
cp $SCRIPT_HOME/files/mgr_context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
cp $SCRIPT_HOME/files/hmgr_context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
#edit files if required (recommend edit tomcat-users.xml to more appropriate password)
#sudo nano /opt/tomcat/conf/tomcat-users.xml
#sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
#sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
#restart tomcat
#systemctl restart tomcat
echo "Finished - Install and configure Tomcat"
###
read -n 1 -s -r -p "install and configure apache..."
###
#Install apache2 (TODO: is this required?)
apt install apache2
#apply changes to apache2.conf as per ERDDAP instructions
cp $SCRIPT_HOME/files/apache2.conf /etc/apache2/apache2.conf
#sudo nano /etc/apache2/apache2.conf
###
echo "Finished - Install and configure apache"

read -n 1 -s -r -p "install and configure ERDDAP content..."
###
#Deploy and configure ERDDAP content zip file
unzip erddapContent.zip
mv /tmp/content /opt/tomcat/
chown -R tomcat:tomcat /opt/tomcat/content
#create bigParentDirectory (location optional, but must be represented in setup.xml
mkdir /home/erddap
chown -R tomcat:tomcat /home/erddap
cp $SCRIPT_HOME/files/setup.xml /opt/tomcat/content/erddap/setup.xml
cp $SCRIPT_HOME/files/server.xml /opt/tomcat/conf/server.xml
cp $SCRIPT_HOME/files/context.xml /opt/tomcat/conf/context.xml
#sudo nano /opt/tomcat/content/erddap/setup.xml - hostname must be updated
#sudo nano /opt/tomcat/conf/server.xml
#sudo nano /opt/tomcat/conf/context.xml
###

###
#Deploy WAR file
mv erddap.war /opt/tomcat/webapps/erddap.war
chown tomcat:tomcat /opt/tomcat/webapps/erddap.war
###
echo "Finished - Install and configure erdapp content"
echo "bigParentDirectory = /home/erddap"
echo "tomcat directory: /opt/tomcat"
echo "Default datasets subset to 'etopo.*'"
echo "tomcat admin username is: admin"
echo "edit this here: /opt/tomcat/conf/tomcat-users.xml'"
echo "start tomcat 'sudo systemctl start tomcat'"


#!/bin/bash
#!/bin/bash
#Ensure script is run as root
[ "$(id -u)" != "0" ] && echo "This script must be executed as root." && exit 1
# set SCRIPT_HOME to location of this script
# Snippet source Itamar Ostricher 2014 
# https://www.ostricher.com/2014/10/the-right-way-to-get-the-directory-of-a-bash-script/
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#user defined variables for editing setup.xml, tomcat-users.xml
function main() {

    userinfo
    userinfowrite

}

function userinfo() {

    read -p "Enter a new password for tomcat-users.xml:" TOMCAT_ADMIN_PASSWD
    read -p "Enter device hostname/IP that will be used in the URL:" HOSTNAME_STR
    read -p "Enter your email address:" EMAIL_ADDR
    read -p "Enter your name:" USER_NAME
    read -p "Enter your company:" USER_CO
    echo "Enter your website..."
    read -p "...http or https?" WEB_PRTCL
    read -p "... domain name?" WEB_DOM
    read -p "Enter your telephone:" USER_PHONE
    read -p "Enter your address line 1:" ADDR_ONE
    read -p "Enter your town:" ADDR_TWO
    read -p "Enter your State or Province:" ADDR_THREE
    read -p "Enter your postcode:" ADDR_FOUR
    read -p "Enter your country:" ADDR_FIVE
    read -p "Enter a short quotation you like:" USER_QUOTE

}

function userinfowrite () {

    sed -i "s/updatePassword/$TOMCAT_ADMIN_PASSWD/g" $SCRIPT_HOME/files/tomcat-users.xml
    sed -i "s/updateHostname/$HOSTNAME_STR/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateEmail/$EMAIL_ADDR/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateName/$USER_NAME/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateCompany/$USER_CO/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateProtocol/$WEB_PRTCL/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateWebsite/$WEB_DOM/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateTelephone/$USER_PHONE/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateAddressLine1/$ADDR_ONE/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateTown/$ADDR_TWO/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateStateProvince/$ADDR_THREE/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updatePostcode/$ADDR_FOUR/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateCountry/$ADDR_FIVE/g" $SCRIPT_HOME/files/setup.xml
    sed -i "s/updateQuote/$USER_QUOTE/g" $SCRIPT_HOME/files/setup.xml

}

main
#install JDK
apt --yes install openjdk-8-jdk
#install unzip
apt --yes install unzip
###
#Download files (note: tmp dir will clear out on reboots, optionally download to homedir and add step to delete at the end)
cd /tmp
wget https://www.mirrorservice.org/sites/ftp.apache.org/tomcat/tomcat-8/v8.5.53/bin/apache-tomcat-8.5.53.tar.gz
wget https://github.com/BobSimons/erddap/releases/download/v2.02/erddapContent.zip
wget https://github.com/BobSimons/erddap/releases/download/v2.02/erddap.war
###
#Install and configure Tomcat
#create tomcat group and user
groupadd tomcat
useradd -s /bin/bash -g tomcat -d /opt/tomcat -p '*' tomcat
#create tomcat home directory
mkdir /opt/tomcat
#unpack tomcat files to tomcat home directory
tar xzvf /tmp/apache-tomcat-*tar.gz -C /opt/tomcat --strip-components=1
#modify ACLS (file permissions) of tomcat directory structure
chgrp -R tomcat /opt/tomcat
chmod -R g+r /opt/tomcat/conf
chmod g+x /opt/tomcat/conf
chown -R tomcat /opt/tomcat/webapps/ /opt/tomcat/work/ /opt/tomcat/temp/ /opt/tomcat/logs/
#create systemd service file (copy from github repo)
cp $SCRIPT_HOME/files/tomcat.service /etc/systemd/system/tomcat.service
systemctl daemon-reload
#enable service start on boot
systemctl enable tomcat
#configure tomcat user for management interfaces
#copy files from git repo
cp $SCRIPT_HOME/files/tomcat-users.xml /opt/tomcat/conf/tomcat-users.xml
cp $SCRIPT_HOME/files/mgr_context.xml /opt/tomcat/webapps/manager/META-INF/context.xml
cp $SCRIPT_HOME/files/hmgr_context.xml /opt/tomcat/webapps/host-manager/META-INF/context.xml
echo "Finished - Install and configure Tomcat"
###
#Install apache2
apt --yes install apache2
#apply changes to apache2.conf as per ERDDAP instructions
cp $SCRIPT_HOME/files/apache2.conf /etc/apache2/apache2.conf
###
echo "Finished - Install and configure apache"
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
###
#Deploy WAR file
mv erddap.war /opt/tomcat/webapps/erddap.war
chown tomcat:tomcat /opt/tomcat/webapps/erddap.war
###
echo "##########################################################"
echo "### Finished - Install and configure erdapp content    ###"
echo "### Notes:                                             ###"
echo "### bigParentDirectory:  /home/erddap                  ###"
echo "### tomcat directory: /opt/tomcat                      ###"
echo "### Default datasets subset to 'etopo.*'               ###"
echo "### tomcat admin username is: admin                    ###"
echo "### edit this here: /opt/tomcat/conf/tomcat-users.xml' ###"
echo "### start tomcat:                                      ###"
echo "###    'sudo systemctl start tomcat' or reboot         ###"
echo "### Browse to http://$HOSTNAME_STR:8080/erddap/        ###"
echo "##########################################################"

# ERDDAP
ERDDAP is a data server that gives you a simple, consistent way to download subsets of gridded and tabular scientific datasets in common file formats and make graphs and maps.
https://coastwatch.pfeg.noaa.gov/erddap/index.html

# This repository
Simple bash script and supporting files that implement the ERDDAP web application version 2.02 on Ubuntu
This script covers my own needs, implementing ERDDAP v2.02 on an Ubuntu server in a few minutes, and I have created it mostly as a learning exercise, and only partly as a convenient tool while I experiment with ERDDAP.

## Instructions
* Clone repo to Ubuntu server: git clone https://github.com/graemediack/erddap_config.git
* Run deploy_erddap.sh as root: sudo ./deploy_erddap.sh
* Follow install, enter details as required.

### Notes:

Some important information if you wish to use it for testing:
* Rolls out the most basic implementation of ERDDAP possible, no SSL, no subscriptions and datasets reduced to example "etopo.*", mostly as per the [ERDDAP Installation Guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html).
* Most file edits noted in the [guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html) are implemented via copying pre-edited files from the *files* directory. See the *file_list* for the names, locations and ACLS (access control details) of these files. I captured the ACLS during my 'why the f*** is it not working this time?!' phase and have left them in place for potential convenience.
* The file *setup.xml* requires user personalised edits, and so I use a big ugly 'read & sed' section to capture user information. Read the notes in setup.xml as per [ERDDAP guidelines](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html).
* Some deviations from the [guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html):
    * Uses default Aptitude package for OpenJDK Version 8 (*openjdk-8-jdk*) including default path (view path with *sudo update-java-alternatives -l*)
    * Installs and configures Tomcat version 8.5.53 as per [Digital Ocean guide](https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-ubuntu-16-04)
        * directory /opt/tomcat
        * web management configured
        * tomcat.service file created and enabled for autostart on boot
            * This service file includes options used in *setenv.sh* therefore I don't create the *setenv.sh* file mentioned in the [guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html) section 2.
* Tested only on Ubuntu 19.10
* Assumes minimum ram of 4GB (java options set to 2GB in *tomcat.service* file

### Files and Directories:
#### deploy_erddap.sh
the bash script
#### file_list
the list of customised files rolled out during install
#### files directory
directory containing files rolled out during install
##### apache2.conf
Apache timeout modifications as per [guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html) section 2. (note this file used to be called httpd.conf)
##### context.xml
Edits applied as per [guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html) section 2.
##### server.xml
Edits applied as per [guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html) section 2.
##### setup.xml
Edited during script run with user defined values as per [guide](https://coastwatch.pfeg.noaa.gov/erddap/download/setup.html) section 3.
##### Tomcat Config Files:
###### hmgr_context.xml (file name change)
Applies web management configuration changes to Tomcat (copied as */opt/tomcat/webapps/host-manager/META-INF/context.xml*)
###### mgr_context.xml (file name change)
Applies web management configuration changes to Tomcat (copied as */opt/tomcat/webapps/manager/META-INF/context.xml*)
###### tomcat-users.xml
Applies web management configuration changes to Tomcat (add admin user *admin*)
###### tomcat.service
Applies tomcat configuration and enables start on boot


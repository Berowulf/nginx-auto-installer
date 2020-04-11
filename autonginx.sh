#!/bin/bash
##Script built and maintained by RootPrivacy.com
##Developer @Root
##Made by https://webhost.sh
##This script is made for debian, specifically 9.x: Stretch;##
##REQUIRED FILES
echo -e 'Before we get started, we will want to make sure that your system is updated.\n
If this is unneccecary, then say "skip", otherwise, just press enter.'
read -p '' -e updateQ
if [[ "$updateQ" != "skip" ]]; then
 apt-get update;
 apt-get upgrade;
  echo -e "$date - System Updated" >> /var/log/autonginx.log
 else
 echo 'Update Skipped.'
 echo -e "$date - Update Skipped" >> /var/log/autonginx.log
fi

if [ $(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo You are missing required files, we will aquire them now. This may take a while. 
  read -p 'Press enter to continue.'
  apt-get install curl;
  apt-get install wget;
  echo -e "$date - Installed Repositories, \n\ CURL, \n\ WGET \n\ " >> /var/log/autonginx.log
fi
clear

#Variables
date=$(date)


echo 'What version of debian are you using?'
echo '1) Debian 8.x: jessie'
echo '2) Debian 9.x: stretch'
echo '3) Debian 10.x: buster'
read -p '' -e versionInUse
if [[ "$versionInUse" != "2" ]]; then
 echo 'Warning: This script is built specifically for Debian 9;'
 echo ''
 echo 'While we have attempted to code in support for all debian systems, it has only been tested on Debian 9.x Systems.'
 read -p 'Press enter to continue.'
 clear
fi

if [[ "$versionInUse" = "2" ]]; then
 echo 'You are running the recommended version!'
 read -p 'Press enter to continue.'
fi
#NGINX START
if [[ "$versionInUse" = "1" ]]; then
	rm /etc/apt/sources.list.d/nginx.list
	cat <<EOF >> /etc/apt/sources.list.d/nginx.list
	deb http://nginx.org/packages/debian/ jessie nginx
	deb-src http://nginx.org/packages/debian/ jessie nginx
EOF
 echo -e "$date - Updated NGINX Repo (Jessie)" >> /var/log/autonginx.log
fi 
if [[ "$versionInUse" = "2" ]]; then
	rm /etc/apt/sources.list.d/nginx.list
	cat <<EOF >> /etc/apt/sources.list.d/nginx.list
	deb http://nginx.org/packages/debian/ stretch nginx
	deb-src http://nginx.org/packages/debian/ stretch nginx
EOF
 echo -e "$date - Updated NGINX Repo (Stretch)" >> /var/log/autonginx.log
fi 
if [[ '$versionInUse' = "3" ]]; then
	rm /etc/apt/sources.list.d/nginx.list
	cat <<EOF >> /etc/apt/sources.list.d/nginx.list
	deb http://nginx.org/packages/debian/ buster nginx
	deb-src http://nginx.org/packages/debian/ buster nginx
EOF
 echo -e "$date - Updated NGINX Repo (Buster)" >> /var/log/autonginx.log
fi 
##
curl -L https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
apt-get update
##install/upgrade NGINX.##
if [ $(dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo 'You do not currently have NGINX installed, doing so now.' 
  #if NGINX is not yet installed.
  read -p 'Press enter to continue.'
  apt-get install nginx;
  echo -e "$date - Installed NGINX" >> /var/log/autonginx.log
  else
  echo 'NGINX is currently installed, will upgrade package.'
  read -p 'Press enter to continue.'
  apt-get upgrade;
  echo -e "$date - Upgraded NGINX" >> /var/log/autonginx.log
fi
clear
systemctl start nginx
systemctl enable nginx
echo 'NGINX install complete;'
echo -e "$date - Completed NGINX Install." >> /var/log/autonginx.log
##NGINX FINISHED


##MYSQL START
##please note; mysql repo is only available in manual download, 
#information may be found here (https://www.digitalocean.com/community/tutorials/how-to-install-the-latest-mysql-on-debian-9)
#Mysql does not get a lot of updates, and most of them should be pushed to your system through apt-update. 
##
if [ $(dpkg-query -W -f='${Status}' mysql-server 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo 'MySQL is not currently installed, correcting now.' 
  read -p 'Press enter to continue.'
  wget https://dev.mysql.com/get/mysql-apt-config_0.8.10-1_all.deb
  sudo dpkg -i mysql-apt-config_0.8.10-1_all.deb
  sudo apt-get update
  apt-get install mysql-server;
  sudo mysql_secure_installation
  echo -e "$date - Installed MySQL-Server & Secured." >> /var/log/autonginx.log
fi
clear
##MySQL FINISHED
##PHP 7.2 START
sudo apt -y install lsb-release apt-transport-https ca-certificates 
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php7.3.list
if [ $(dpkg-query -W -f='${Status}' php7.3 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo 'PHP is not currently installed, correcting now.' 
  read -p 'Press enter to continue.'
  sudo apt-get update;
  apt-get install php7.3;
  apt-get install php7.3-fpm && apt-get install php7.3-mysql && apt-get install php7.3-curl
  apt-get install php7.3-mbstring
  apt-get install php-mbstring php7.3-mbstring php-gettext
  sed -i 's/listen.owner = www-data/listen.owner = nginx/g' /etc/php/7.3fpm/pool.d/www.conf
  sed -i 's/listen.group = www-data/listen.group = nginx/g' /etc/php/7.3/fpm/pool.d/www.conf
  systemctl reload nginx;
  nginx -s reload

  echo -e "$date - Installed PHP, \n PHP-FPM \n PHP MYSQL \n PHP CURL \n" >> /var/log/autonginx.log
fi
clear
##PHP END

##phpMyAdmin Start
if [ $(dpkg-query -W -f='${Status}' phpmyadmin 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo 'phpMyAdmin is not currently installed, correcting now.' 
  read -p 'Press enter to continue.'
  sudo apt-get update;
  apt-get install phpmyadmin
  echo -e "$date - Installed phpMyAdmin \n" >> /var/log/autonginx.log
fi
clear
##phpmyadmin FINISHED

#More Configuration

# websiteROOTDIRECTORY='/usr/share/nginx/html by default'
#sudo ln -s /usr/share/phpmyadmin $websiteROOTDIRECTORY
#cd $websiteROOTDIRECTORY
#sudo mv phpmyadmin ducksfindprivacyinthedepthsoftheirfeathers



##FOR FUTURE WHEN CONFIG IS ALL SETUP
echo 'Would you like to setup nginx with the common configuration? (Y/N)'#
read -p '' -e YN
if [[ "$YN" = "Y" || "$YN" = "y" ]]; then
 clear
 echo -e 'WARNING - This will corrupt all current configurations.'
 echo 'Are you sure you want to continue? (Y/N)'
 read -p '' -e YN
 if [[ "$YN" = "Y" || "$YN" = "y" ]]; then
    echo -e "$date - Copied current NGINX config to /var/log/autonginx.savednginx.conf.d \n" >> /var/log/autonginx.log
	echo -e "$date - pushing pre-config files to nginx. \n" >> /var/log/autonginx.log
    cp /etc/nginx/conf.d/default.conf /var/log/autonginx.savednginx.conf.d
	rm -Rf /etc/nginx/conf.d/default.conf
	echo 'What is your server domain? (EX: rootprivacy.com)'
	read -p '' -e SERVERNAME
TEA='$document_root$fastcgi_script_name'
TEA2='$fastcgi_script_name'
	cat <<EOF >> /etc/nginx/conf.d/default.conf
server {
    listen         80 default_server;
    listen         [::]:80 default_server;
    server_name    $SERVERNAME;
    root           /var/www;
    index          index.html;

  location ~* \.php$ {
    fastcgi_pass unix:/run/php/php7.3-fpm.sock;
    include         fastcgi_params;
    fastcgi_param   SCRIPT_FILENAME    $TEA;
    fastcgi_param   SCRIPT_NAME        $TEA2;
  }
  location /phpmyadmin {
     index index.php index.html index.htm;
     root /usr/share;
}
  location /phpmyadmin {
   index index.php index.html index.htm;
   root /var/www;
}
}


EOF
 fi
fi



#echo 'Be sure to edit the PHP.INI file and set cgi.fix_pathinfo = 0'

echo 'All installations complete.'
echo -e "$date - All required updates/installs are complete." >> /var/log/autonginx.log
read -p 'Press enter to quit.'
exit 









##ubuntu - not currently supported
#If a W: GPG error: http://nginx.org/packages/ubuntu xenial Release: The following signatures
#couldn't be verified because the public key is not available: NO_PUBKEY $key is encountered during the 
#NGINX repository update, execute the following:
#Replace $key with the corresponding $key from your GPG error.
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key
#sudo apt-get update
#sudo apt-get install nginx
#read -p 'Was a public key error encountered? (Y/N)' -e Q
#if [[ "$Q" = 'Y' | "$Q" = "y" ]]; then
# read -p 'In case of public key error, then type in the key from the GPG error now.' -e key
# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key
# sudo apt-get update
# sudo apt-get install nginx
#fi
##
##

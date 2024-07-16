#!/bin/sh

#
# Vulnerable wordpress server: WordPress Plugin Wp-FileManager 6.8 - RCE 
# wget https://downloads.wordpress.org/plugin/wp-file-manager.6.0.zip
# https://www.exploit-db.com/exploits/49178
# 
#

#
# Globals
#
DB_PASSWD_ROOT=password
DB_PASSWD_WP=password
WP_ADMIN_LOGIN=wordpress_admin
WP_ADMIN_PASSWD=myadminpassword
WP_TITLE="Turtle World"
WP_URL="http://localhost:8090"
VERBOSE=false

#
# Usage
#
usage () {
  echo "Usage: $0 [options]" 1>&2; 
  echo "[-dbpr XXXX] : set DB Root password" 1>&2; 
  echo "[-dbpw XXXX] : set DB Wordpress user password" 1>&2; 
  echo "[-wpl XXXX] : set wordpress site admin login" 1>&2; 
  echo "[-wpp XXXX] : set wordpress site admin password" 1>&2; 
  echo "[-wt XXXX] : set wordpress site title" 1>&2; 
  echo "[-wu XXXX] : set wordpress site external url" 1>&2; 
  echo "[-v] : set verbose" 1>&2;
  exit 1;
}




#
# Parse arguments
#
echo "Parsing command line options."
while [[ $# -gt 0 ]]; do
  case $1 in
    -dbpr)
      DB_PASSWD_ROOT="$2"
      shift # past argument
      shift # past value
      ;;
    -dbpw)
      DB_PASSWD_WP="$2"
      shift # past argument
      shift # past value
      ;;
    -wpl)
      WP_ADMIN_LOGIN="$2"
      shift # past argument
      shift # past value
      ;;
    -wpp)
      WP_ADMIN_PASSWD="$2"
      shift # past argument
      shift # past value
      ;;
    -wt)
      WP_TITLE="$2"
      shift # past argument
      shift # past value
      ;;
    -wu)
      WP_URL="$2"
      shift # past argument
      shift # past value
      ;;
    -v)
      VERBOSE="$2"
      shift # past argument
      ;;
	-*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done



# Activate community repo
sudo sed -i '/#http:\/\/dl-cdn.alpinelinux.org\/alpine\/v3.17\/community/c\http:\/\/dl-cdn.alpinelinux.org\/alpine\/v3.17\/community' /etc/apk/repositories
sudo apk update

# Allow ssh port forwarding
sudo sed -i '/AllowTcpForwarding no/c\AllowTcpForwarding yes'  /etc/ssh/sshd_config

# Install apk
sudo apk add --no-cache     ttyd     bash     zip  curl  fstrim \
    nginx     php81     php81-fpm     php81-session  \
	php81-pdo_sqlite     php81-curl     php81-mysqli   \
	php81-mysqlnd     php81-openssl     php81-pdo  \
	php81-pdo_dblib     php81-pdo_mysql     php81-pdo_odbc \
    php81-pdo_pgsql     php81-pdo_sqlite     php81-sqlite3  php81-phar \
	php81-iconv php81-zip \
	mariadb  mariadb-client   
	
	
#
# mariadb
#
sudo rc-update add mariadb default

# create root and mysql mara account (no password)
sudo  /usr/bin/mariadb-install-db --user=mysql --datadir='/var/lib/mysql'

sudo rc-service mariadb start
sleep 4
echo '## Mariadb mysqladmin set root password'
sudo /usr/bin/mariadb-admin -u root password "$DB_PASSWD_ROOT"

printf "\n##\n## Mariadb Fill database with wordpress"
echo 'CREATE DATABASE /*!32312 IF NOT EXISTS*/ `wordpress_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;' | mysql -u root --password="$DB_PASSWD_ROOT"
printf "GRANT ALL ON wordpress_db.* to 'wp_user'@'%%' IDENTIFIED BY '$DB_PASSWD_WP'; GRANT ALL ON wordpress_db.* to 'wp_user'@'localhost' IDENTIFIED BY '$DB_PASSWD_WP'; FLUSH PRIVILEGES;" | mysql -u root --password="$DB_PASSWD_ROOT"
echo '## Mariadb config done'  


#
# wordpress 
#
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo mv wp-cli.phar /bin/wp-cli 
sudo chmod a+rx /bin/wp-cli 


sudo adduser -D -g 'www' --home /www --shell /sbin/nologin www
sudo mkdir -p /www
sudo chmod a+rwx /www
sudo chown -R www:www /www

cd /www
wp-cli core download --version=5.5
wp-cli core config --dbhost=localhost --dbname=wordpress_db --dbuser=wp_user --dbpass="$DB_PASSWD_WP"
wp-cli core install --url="$WP_URL" --title="$WP_TITLE" --admin_name="$WP_ADMIN_LOGIN" --admin_password="$WP_ADMIN_PASSWD" --admin_email=you@example.com


mkdir -p /www/wp-content/uploads
chmod 775 /www/wp-content/uploads

# wp-cli plugin install --version=6.0 file-manager
# wp-cli plugin activate  file-manager
sudo wget https://downloads.wordpress.org/plugin/wp-file-manager.6.0.zip
sudo mkdir tmp
sudo unzip wp-file-manager.6.0.zip -d tmp/
sudo unzip tmp/wp-file-manager/wp-file-manager-6.O.zip -d wp-content/plugins/


# Desactive http to https redirection
sudo sh -c "echo \"define('WP_HOME', '$WP_URL');\">> /www/wp-config.php"


# services 
sudo rc-update add php-fpm81 default
sudo rc-update add nginx default


#
# nginx 
#
sudo chown -R www:www /var/lib/nginx

sudo cp /home/vagrant/nginx_http_d_default.conf /etc/nginx/http.d/default.conf
sudo chown www:www /etc/nginx/nginx.conf

sudo cp /home/vagrant/php_fpm_www.conf /etc/php81/php-fpm.d/www.conf
sudo chown www:www /etc/php81/php-fpm.d/www.conf

sudo cp /home/vagrant/profile_php8.sh /etc/profile.d/php8.sh
chmod a+rx /etc/profile.d/php8.sh
 
 
sudo rc-service php-fpm81 start
sudo rc-service nginx start



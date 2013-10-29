#!/bin/bash

clear


### Configuration

# Magento
magentoDatabase="db_magento"
magentoDatabaseUser="usr_magento"
magentoDatabasePassword="magento"
magentoAdminPassword="magento"
magentoURL="localhost/"
magentoVersion="1.8.0.0"
magentoSampleDataVersion="1.6.1.0"

# Other
mysqlRootPassword=webvuln
apacheDir=/var/www
scriptTmpFolder=~/tmp_webvulnTargets


### Create temporary directory for downloads etc.
mkdir -p $scriptTmpFolder

### Install dependencies
# Install MySQL server and client
type mysql >/dev/null 2>&1 && \
	echo "" \
	echo "MySQL already installed" || \
	echo "" \
	echo "MySQL installing..." \
	echo "" \
	sudo DEBIAN_FRONTEND=noninteractive apt-get -qq --force-yes install mysql-server mysql-client > /dev/null \
	mysqladmin -u root password $mysqlRootPassword

# Install Apache2
echo ""
echo "Installing Apache2 and PHP5..."
sudo DEBIAN_FRONTEND=noninteractive apt-get --force-yes -y install apache2 php5 libapache2-mod-php5 php5-mysql php5-curl php5-gd php-pear php5-imagick php5-memcache php5-ming > /home/user/test123 #dev/null
sudo chown -R $USER:users /var/www 
echo "------restarting Apache2"
sudo /etc/init.d/apache2 restart

# get Magento and sample data
echo ""
echo "Downloading Magento with sample data"
cd $scriptTmpFolder
#wget http://www.magentocommerce.com/downloads/assets/1.8.0.0/magento-1.8.0.0.tar.gz 
#wget http://www.magentocommerce.com/downloads/assets/1.6.1.0/magento-sample-data-1.6.1.0.tar.gz 

# Using a private mirror during development to avoid extreme low speeds on magentocommerce
wget http://www.vg-dev.de/magento/magento-$magentoVersion.tar.gz
wget http://www.vg-dev.de/magento/magento-sample-data-$magentoSampleDataVersion.tar.gz 

echo "--- extracting files..."
tar zxf magento-$magentoVersion.tar.gz -C $apacheDir > /dev/null
tar xvfz magento-sample-data-$magentoSampleDataVersion.tar.gz > /dev/null

echo "--- creating database and user"
SQL1="CREATE DATABASE IF NOT EXISTS $magentoDatabase;"
SQL2="GRANT ALL PRIVILEGES ON "$magentoDatabase".* TO '$magentoDatabaseUser'@'localhost' IDENTIFIED BY '$magentoDatabasePassword';"
SQL3="FLUSH PRIVILEGES;"
mysql -uroot -p$mysqlRootPassword -e "${SQL1}${SQL2}${SQL3}"

echo "--- importing sample data"
cd $scriptTmpFolder/magento-sample-data-$magentoSampleDataVersion
mysql -h localhost -u$magentoDatabaseUser -p$magentoDatabasePassword $magentoDatabase < magento_sample_data_for_$magentoSampleDataVersion.sql
mv media $apacheDir/magento/media

echo "--- setting permissions"
cd $apacheDir/magento
chmod 550 mage
chmod 777 -R var/cache

echo "--- preparing installation"
# remove possible existing cache files (to prevent a ZEND exception during install)
rm -rf var/session var/cache
./mage mage-setup .
./mage config-set preferred_state stable
./mage install http://connect20.magentocommerce.com/community Mage_All_Latest --force
php -f shell/indexer.php reindexall

echo "--- installing magneto"
php -f install.php -- \
    --license_agreement_accepted "yes" \
    --locale "de_DE" \
    --timezone "Europe/Berlin" \
    --default_currency "EUR" \
    --db_host "localhost" \
    --db_name "$magentoDatabase" \
    --db_user "$magentoDatabaseUser" \
    --db_pass "$magentoDatabasePassword" \
    --url "$magentoURL" \
    --use_rewrites "yes" \
    --use_secure "no" \
    --secure_base_url "" \
    --use_secure_admin "no" \
    --admin_firstname "Webvulnscan" \
    --admin_lastname "Test" \
    --admin_email "test@example.com" \
    --admin_username "admin" \
    --admin_password "$magentoAdminPassword"

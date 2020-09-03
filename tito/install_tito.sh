#!/bin/bash

# Get and display parameters
SQLSERVER=$1
HTTPDCONF=/etc/httpd/conf/httpd.conf
echo "HTTPDCONF=$HTTPDCONF"


# Install httpd
#rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
#yum --enablerepo=remi,remi-php72 install -y httpd php php-common
yum install httpd -y
/usr/sbin/service httpd start
yum install php -y
yum install php-mysql -y
/usr/sbin/chkconfig httpd on

# Install python3 and libraries
yum install -y python36 python-pip python36-setuptools gcc python3-devel
easy_install-3.6 pip
pip3 install wavefront-opentracing-sdk-python --no-cache-dir

#Set timezone
echo
echo -e "conf php.ini Timezone \n"

echo "date.timezone = \"Europe/Rome\"" >> /etc/php.ini

#Setup db address
echo
echo -e "conf httpd.conf to include PHP and set MySQL server\n"

echo
echo -e "modify SQLSERVER variable to remove not needed characters"
SQLSERVER=$(tr -d []\' <<< $SQLSERVER)

echo
echo "LoadModule php5_module modules/libphp5.so" >> $HTTPDCONF
cat <<EOF >> $HTTPDCONF
<IfModule env_module>
    SetEnv TITO-SQL "$SQLSERVER"
</IfModule>
EOF

# Install tito
git clone https://github.com/phan-t/anz-cm-lab.git /var/tmp/anz-cm-lab
cp -a /var/tmp/anz-cm-lab/tito/var/www/html /var/www/html
cd /var/www/html


# config httpd.conf
sed -i '/<Directory "\/var\/www\/html">/a AddHandler cgi-script .cgi .pl .py' /etc/httpd/conf/httpd.conf
sed -i '/<Directory "\/var\/www\/html">/a Options +ExecCGI' /etc/httpd/conf/httpd.conf

# Start httpd
systemctl restart httpd
systemctl enable httpd

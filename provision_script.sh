#!/usr/bin/env bash

PROJECT_NAME="samsara"
PGSQL_VERSION="9.6"
LQBASE_VERSION="3.5.3"
RDS_REGION="eu-central-1"

mkdir /vagrant/$PROJECT_NAME

PROJECT_DIR="/vagrant/$PROJECT_NAME"

LQBASE_DIR="$PROJECT_DIR/liquibase"
LQBASE_URL="https://github.com/liquibase/liquibase/releases/download/liquibase-parent-$LQBASE_VERSION/liquibase-$LQBASE_VERSION-bin.tar.gz"
PGSQL_JDBC_URL="https://jdbc.postgresql.org/download/postgresql-42.1.4.jar"

export DB_USER=`grep username /vagrant/creds | awk '{print $2}'`
export DB_PASS=`grep pass /vagrant/creds | awk '{print $2}'`
export DB_NAME=`grep database /vagrant/creds | awk '{print $2}'`

DB_INS_ID='rds-ripkort'

#sudo add-apt-repository ppa:webupd8team/java
#sudo echo "deb http://apt.postgresql.org/pub/repos/apt/ $LINUX_DIST-pgdg main" > /etc/apt/sources.list.d/pgdg.list
#wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
#  sudo apt-key add -

sudo apt-get update
sudo apt-get -y install openjdk-8-jdk python3-pip #postgresql-$PGSQL_VERSION
sudo pip3 install boto3 awscli

mkdir ~/.aws
cp /vagrant/credentials ~/.aws/

#DB_INSTANCE=`aws rds describe-db-instances --region $RDS_REGION --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port]' --output text | grep ${DB_INS_ID}`
#if [[ -n DB_INSTANCE ]]; then
#	aws rds delete-db-instance --db-instance-identifier ${DB_INS_ID} --region $RDS_REGION --skip-final-snapshot
#	aws rds wait db-instance-deleted --db-instance-identifier ${DB_INS_ID} --region $RDS_REGION
#fi

#aws rds create-db-instance --db-instance-identifier ${DB_INS_ID} --db-instance-class db.t2.micro --engine postgres --backup-retention-period 0 --storage-type standard --allocated-storage 5 --region ${RDS_REGION} --db-name ${DB_NAME} --master-username ${DB_USER} --master-user-password ${DB_PASS}
#aws rds wait db-instance-available --db-instance-identifier ${DB_INS_ID}  --region ${RDS_REGION}

DB_INSTANCE=`aws rds describe-db-instances --region $RDS_REGION --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,Endpoint.Port]' --output text | grep ${DB_INS_ID}`

export DB_HOST=`echo ${DB_INSTANCE} | awk '{print $2}'`
export DB_PORT=`echo ${DB_INSTANCE} | awk '{print $3}'`

mkdir $LQBASE_DIR
cd $LQBASE_DIR

wget $LQBASE_URL 
wget $PGSQL_JDBC_URL 

echo "driver: org.postgresql.Driver
url: jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME
username: $DB_USER 
password: $DB_PASS 

# specifies packages where entities are and database dialect, used for liquibase:diff command 
referenceUrl=hibernate:spring:academy.softserve.aura.core.entity?dialect=org.hibernate.dialect.PostgreSQL9Dialect" > liquibase.properties

sudo tar -xzf liquibase-$LQBASE_VERSION-bin.tar.gz

python3 /vagrant/downloader_s3.py

bash liquibase --defaultsFile=$LQBASE_DIR/liquibase.properties --changeLogFile=/vagrant/liquibase/changelogs/changelog-main.xml --classpath=$PROJECT_DIR/liquibase/postgresql-42.1.4.jar update
java -jar Samsara-1.3.5.RELEASE.jar &


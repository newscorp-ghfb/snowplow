#!/bin/bash


WORKDIR="$(dirname "$0")"
JAR_FILE="2-collectors/scala-stream-collector/kinesis/target/scala-2.11/snowplow-stream-collector-kinesis-0.15.0.jar"

cd "$WORKDIR"
mkdir -p target/common

# TODO: include ivy-cache 

# change into scala-stream-collector directory
cd 2-collectors/scala-stream-collector 

# build jar
if [ -z "$1" ]
then
	sbt "project kinesis" assembly
else
	sbt -Dsbt.ivy.home=$1 "project kinesis" assembly
fi

cd ../..
cp -R $JAR_FILE target/common/snowplow-stream-collector.jar
echo "jar copied to target/common"

cp -r scripts target/common/

mkdir -p target/us/collectorApp/config
mkdir -p target/sit/collectorApp/config

cp -R target/common/* target/us/collectorApp/
# Using the tmp direcotry creation so that it works on MacOs and Linux
sed -e 's/collector-THISWILLCHANGE-stdout.log/collector-usprod-stdout.log/g' target/us/collectorApp/scripts/start_collector.sh >tmp_1.sh
mv tmp_1.sh target/us/collectorApp/scripts/start_collector.sh
cp config/collector-us.conf target/us/collectorApp/config/collector.conf
cp appspec.yml target/us/
cp deploy_aws_code_deploy_revision.sh target/us/
cd target/us
tar -cvf ../collector-us.zip *
cd ../..

cp -R target/common/* target/sit/collectorApp/
# Using the tmp direcotry creation so that it works on MacOs and Linux
sed -e 's/collector-THISWILLCHANGE-stdout.log/collector-ausit-stdout.log/g' target/sit/collectorApp/scripts/start_collector.sh >tmp_1.sh
mv tmp_1.sh target/sit/collectorApp/scripts/start_collector.sh
cp config/collector-sit.conf target/sit/collectorApp/config/collector.conf
cp appspec.yml target/sit/
cp deploy_aws_code_deploy_revision.sh target/sit/
cd target/sit
tar -cvf ../collector-sit.zip *
cd ../..

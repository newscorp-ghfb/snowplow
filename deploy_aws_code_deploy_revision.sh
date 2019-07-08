#!/bin/bash

# Deployment commands Examples:
#
# aws deploy push \
# --application-name ncg-collector-sit \
# --s3-location s3://bamboo-builds-test/collector/sit/collector-RELEASE_NO.zip \
# --source /Users/abrahamg/CODE/ncg-collector/target/sit
#
# aws deploy create-deployment \
# --application-name ncg-collector-sit \
# --s3-location bucket=bamboo-builds-test,key=collector/sit/collector-RELEASE_NO.zip,bundleType=zip \
# --deployment-group-name ncg-collector \
# --deployment-config-name CodeDeployDefault.AllAtOnce
#
#
# Usage of this script example :
#   sh deploy_aws_code_deploy_revision.sh \
#   --appname ncg-collector-sit \
#   --releaseno RELEASE1 \
#   --deploymentgroup ncg-collector \
#   --deploymentconfig CodeDeployDefault.AllAtOnce \
#   --s3bucketname bamboo-builds-test \
#   --env SIT


#!/bin/bash

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--appname)
    APP_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--releaseno)
    RELEASE_NUMBER="$2"
    shift # past argument
    shift # past value
    ;;
    -e|--env)
    ENVIRONMENT="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--deploymentgroup)
    DEPLOYMENT_GROUP="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--s3bucketname)
    S3_BUCKET_NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--deploymentconfig)
    DEPLOYMENT_CONFIG="$2"
    shift # past argument
    shift # past value
    ;;
    -r|--deploymentregion)
    DEPLOYMENT_REGION="$2"
    shift # past argument
    shift # past value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

echo APP_NAME            = "${APP_NAME}"
echo RELEASE_NUMBER      = "${RELEASE_NUMBER}"
echo DEPLOYMENT_GROUP    = "${DEPLOYMENT_GROUP}"
echo DEPLOYMENT_CONFIG   = "${DEPLOYMENT_CONFIG}"
echo DEPLOYMENT_REGION   = "${DEPLOYMENT_REGION}"
echo S3_BUCKET_NAME      = "${S3_BUCKET_NAME}"
echo ENVIRONMENT         = "${ENVIRONMENT}"


if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi

echo "Pushing Revision to S3 and CodeDeploy"

aws deploy push \
--application-name ${APP_NAME} \
--s3-location s3://${S3_BUCKET_NAME}/${APP_NAME}/${ENVIRONMENT}/${APP_NAME}-${RELEASE_NUMBER}.zip \
--region ${DEPLOYMENT_REGION} \
--source .


echo "Create Deployment in CodeDeploy"

getDeployId (){
aws deploy create-deployment \
--file-exists-behavior OVERWRITE \
--application-name ${APP_NAME} \
--s3-location bucket=${S3_BUCKET_NAME},key=${APP_NAME}/${ENVIRONMENT}/${APP_NAME}-${RELEASE_NUMBER}.zip,bundleType=zip \
--deployment-group-name ${DEPLOYMENT_GROUP} \
--deployment-config-name ${DEPLOYMENT_CONFIG} \
--region ${DEPLOYMENT_REGION}
}

echo "Parsing JSON for Deployment ID"

json=$(getDeployId)
prop="deploymentId"

function jsonval {
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop`
    echo ${temp##*|} | cut -d':' -f2 | xargs
}

deployment_id=$(jsonval)

echo "Watching Deployment Deployment ID : ${deployment_id}"

aws deploy wait deployment-successful --deployment-id ${deployment_id} --region ${DEPLOYMENT_REGION}

if [ $? -eq 0 ]; then
    echo "Deployment Successful"
else
    echo "Deployment Failed !!"
    exit 2
fi
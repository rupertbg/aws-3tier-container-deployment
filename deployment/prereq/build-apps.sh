#!/bin/bash

OUTPUT_FILE="output.json"
echo -n "{" > $OUTPUT_FILE
IMAGE_TAG=`TZ=UTC date +%Y.%m.%d.%H%M`
APPS="applications/*"
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com

LAST_APP=""
for DIR in $APPS; do
  APP=$(basename $DIR)
  IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$GITHUB_REPO_OWNER/$GITHUB_REPO_NAME/$APP:$IMAGE_TAG";
  echo "Building the Docker image for $IMAGE_TAG";
  docker build -t $IMAGE $DIR
  docker push $IMAGE;
  if [ ! -z $LAST_APP ]; then
    cat >> output.json << EOF
"$APP":"$IMAGE",
EOF
  fi
  LAST_APP=$APP
done

if [ ! -z $LAST_APP ]
then
  if [ ! -z $LAST_APP ]; then
    cat >> output.json << EOF
"$APP":"$IMAGE"}
EOF
  fi
fi

exit 0;

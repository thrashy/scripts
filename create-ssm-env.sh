#!/bin/bash

# convert AWS parameter store values into a .env file
# usage ./create-env.sh </PATH/TO/PROJECT/> <AWS_PROFILE> <QUOTE>
# the third parameter is used to quote values if set to 1, set it to 0 to not quote
# the aws cli and sed should be on PATH

PARAM_PATH=$1
PROFILE=$2
QUOTED=$3

if [ $QUOTED -eq "1" ]
then
	aws ssm get-parameters-by-path \
	--with-decryption \
	--recursive \
	--path "$PARAM_PATH" \
	--profile $PROFILE \
	--output text \
	--query "Parameters[].[Name,Value]" |
	sed 's/"/\\"/g' |
	sed 's/\\n/\\\\n/g' |
	sed -E "s|$PARAM_PATH([^[:space:]]*)[[:space:]]*(.*)$|\1=\"\2\"|"
else
	aws ssm get-parameters-by-path \
	--with-decryption \
	--recursive \
	--path "$PARAM_PATH" \
	--profile $PROFILE \
	--output text \
	--query "Parameters[].[Name,Value]" |
	sed -E "s|$PARAM_PATH([^[:space:]]*)[[:space:]]*|\1=|"
fi
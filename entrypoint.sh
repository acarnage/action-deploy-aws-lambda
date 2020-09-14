#!/bin/bash

deploy_function() {
	echo "Deploying function ..."
	zip -r code.zip . -x \*.git\*
	aws lambda create-function --function-name "${INPUT_FUNCTION_NAME}" --runtime "${INPUT_RUNTIME}" --role "${INPUT_ROLE}" --handler "${INPUT_HANDLER}" --zip-file fileb://code.zip
}

update_function() {
	echo "Updating function ..."
	zip -r code.zip . -x \*.git\*
	aws lambda update-function-code --function-name "${INPUT_FUNCTION_NAME}" --zip-file fileb://code.zip
}

deploy_or_update_function() {
    echo "Checking function existence..."
	aws lambda get-function --function-name "${INPUT_FUNCTION_NAME}" &> /dev/null
	if [ $? != 0 ]
	then
		echo "Function ${INPUT_FUNCTION_NAME} not found, running initial deployment..."
		deploy_function
	else
		echo "Function found, updating ..."
		update_function
    fi
    echo "Done."
}

deploy_or_update_function
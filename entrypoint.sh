#!/bin/bash

deploy_function() {
	echo "Deploying function ..."
	cd "${INPUT_WORKING_DIRECTORY}"
	zip -r code.zip . -x \*.git\*
	aws lambda create-function --function-name "${INPUT_FUNCTION_NAME}" --runtime "${INPUT_RUNTIME}" --role "${INPUT_ROLE}" --handler "${INPUT_HANDLER}" --zip-file fileb://code.zip
}

update_function() {
	echo "Updating function ..."
	cd "${INPUT_WORKING_DIRECTORY}"
	zip -r code.zip . -x \*.git\*
	echo aws lambda update-function-configuration --function-name "${INPUT_FUNCTION_NAME}" --runtime "${INPUT_RUNTIME}" --role "${INPUT_ROLE}" --handler "${INPUT_HANDLER}"
	aws lambda update-function-configuration --function-name "${INPUT_FUNCTION_NAME}" --runtime "${INPUT_RUNTIME}" --role "${INPUT_ROLE}" --handler "${INPUT_HANDLER}"
	echo aws lambda update-function-code --function-name "${INPUT_FUNCTION_NAME}" --zip-file fileb://code.zip
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

show_environment() {
	echo "Function name: ${INPUT_FUNCTION_NAME}"
	echo "Runtime: ${INPUT_RUNTIME}"
	echo "IAM role: ${INPUT_ROLE}"
	echo "Lambda handler: ${INPUT_HANDLER}"
	echo "Working directory: ${INPUT_WORKING_DIRECTORY}"
}

show_environment
deploy_or_update_function
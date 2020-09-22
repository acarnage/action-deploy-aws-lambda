#!/bin/bash

add_requirements() {
	if [ -f "requirements.txt" ]
	then
		echo "Installing requirements..."
		pip install -r requirements.txt -t .
    fi
}

deploy_function() {
	echo "Deploying function ..."
	cd "${INPUT_WORKING_DIRECTORY}"
	add_requirements
	zip -r code.zip . -x \*.git\*
	aws lambda create-function --function-name "${INPUT_FUNCTION_NAME}" --runtime "${INPUT_RUNTIME}" \
		--timeout "${INPUT_TIMEOUT}" --memory-size "${INPUT_MEMORY}" --role "${INPUT_ROLE}" \
		--handler "${INPUT_HANDLER}" --zip-file fileb://code.zip
}

update_function() {
	echo "Updating function ..."
	cd "${INPUT_WORKING_DIRECTORY}"
	add_requirements
	zip -r code.zip . -x \*.git\*
	aws lambda update-function-configuration --function-name "${INPUT_FUNCTION_NAME}" --runtime "${INPUT_RUNTIME}" \
		--timeout "${INPUT_TIMEOUT}" --memory-size "${INPUT_MEMORY}" --role "${INPUT_ROLE}" \
		--handler "${INPUT_HANDLER}"
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
		echo "Function found, updating..."
		update_function
    fi
    echo "Done."
}

show_environment() {
	echo "Function name: ${INPUT_FUNCTION_NAME}"
	echo "Runtime: ${INPUT_RUNTIME}"
	echo "Memory size: ${INPUT_MEMORY}"
	echo "Timeout: ${INPUT_TIMEOUT}"
	echo "IAM role: ${INPUT_ROLE}"
	echo "Lambda handler: ${INPUT_HANDLER}"
	echo "Working directory: ${INPUT_WORKING_DIRECTORY}"
}

echo "dpolombo/action-deploy-aws-lambda@v1.5"
show_environment
deploy_or_update_function
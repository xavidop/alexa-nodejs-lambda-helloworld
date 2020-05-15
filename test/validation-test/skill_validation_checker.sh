#!/bin/bash
skill_id=$1

cli_version=$2

echo "######### Checking validations #########"

if [[ ${cli_version} == *"v1"* ]]
then
    folder="../../models/*"
else
    folder="../../skill-package/interactionModels/*"
fi


for d in ${folder}; do

    file_name="${d##*/}"
    locale="${file_name%.*}"

    echo "Checking validations for locale: ${locale}"
    echo "###############################"

    if [[ ${cli_version} == *"v1"* ]]
    then
        validations=$(ask api validate-skill -s ${skill_id} -l ${locale})
    else
        validations=$(ask smapi submit-skill-validation -s ${skill_id} -l ${locale} -g development)
    fi


    id=$(jq ".id" <<< ${validations})
    #Remove quotes
    id=$(echo "${id}" | sed 's/"//g')
    echo "Id of validation: ${id}"
    status="IN_PROGRESS"

    while [[ ${status} == *"IN_PROGRESS"* ]]; do

        if [[ ${cli_version} == *"v1"* ]]
        then
            status_raw=$(ask api get-validation -i ${id} -s ${skill_id})
        else
            status_raw=$(ask smapi get-skill-validations --validation-id ${id} -s ${skill_id} -g development)
        fi

        status=$(jq ".status" <<< ${status_raw})
        echo "Current status: ${status}"
        
        if [[ ${status} == *"IN_PROGRESS"* ]]
        then
            echo "Waiting for finishing the validation..."
            sleep 15
        fi

    done

    if [[ ${status} == *"SUCCESSFUL"* ]]
    then
        echo "Validation pass"
        exit 0
    else
        echo "Validation errors: ${status_raw}"
        exit 1
    fi

done
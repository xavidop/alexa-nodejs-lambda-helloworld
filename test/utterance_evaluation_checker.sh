#!/bin/bash
skill_id=$1

cli_version=$2

echo "######### Checking Utterance Evaluation #########"

if [[ ${cli_version} == *"v1"* ]]
then
    folder="../models/*"
else
    folder="../skill-package/interactionModels/*"
fi

for d in ${folder}; do

    file_name="${d##*/}"
    locale="${file_name%.*}"

    echo "Checking Utterance evaluation for locale: ${locale}"
    echo "###############################"

    while IFS="" read -r  annotation || [ -n "${annotation}" ]; do

        #clean end of lines
        annotation=$(echo ${annotation} | sed -e 's/\r//g')
        echo "Annotation to test: ${annotation}"
        if [[ ${cli_version} == *"v1"* ]]
        then
            evaluation=$(ask api evaluate-nlu -a ${annotation} -s ${skill_id} -l ${locale})
        else
            evaluation=$(ask smapi create-nlu-evaluations --source-annotation-id ${annotation} -s ${skill_id} -l ${locale} -g development)
        fi

        id=$(jq ".id" <<< ${evaluation})
        #Remove quotes
        id=$(echo "${id}" | sed 's/"//g')
        echo "Id of evaluation: ${id}"
        status="IN_PROGRESS"

        while [[ ${status} == *"IN_PROGRESS"* ]]; do

            if [[ ${cli_version} == *"v1"* ]]
            then
                status_raw=$(ask api get-nlu-evaluation -e ${id} -s ${skill_id})
            else
                status_raw=$(ask smapi get-nlu-evaluation --evaluation-id ${id} -s ${skill_id})
            fi

            status=$(jq ".status" <<< ${status_raw})
            echo "Current status: ${status}"
            
            if [[ ${status} == *"IN_PROGRESS"* ]]
            then
                echo "Waiting for finishing the evaluation..."
                sleep 15
            fi

        done

        echo "Utterance evaluation finished"

        if [[ ${status} == *"PASSED"* ]]
        then
            echo "No Utterance evaluation errors"
        else
            echo "Utterance evaluation error"
            echo "Evaluation: ${status_raw}"
            exit 1
        fi

    done < "utterance_evaluation/${locale}"

done
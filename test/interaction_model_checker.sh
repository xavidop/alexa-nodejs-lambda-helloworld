#!/bin/bash
skill_id=$1

cli_version=$2

echo "######### Checking Conflicts #########"

if [[ ${cli_version} == *"v1"* ]]
then
    folder="../models/*"
else
    folder="../skill-package/interactionModels/*"
fi

for d in ../models/*; do

    file_name="${d##*/}"
    locale="${file_name%.*}"

    echo "Checking conflicts for locale: ${locale}"
    echo "###############################"

    if [[ ${cli_version} == *"v1"* ]]
    then
        conflicts=$(ask api get-conflicts -s ${skill_id} -l ${locale})
    else
        #Bug opened: https://github.com/alexa/ask-cli/issues/180
        conflicts=$(ask smapi get-conflicts -s ${skill_id} -l ${locale})
    fi

    if [[ ${conflicts} == "{}" ]]
    then
        echo "No Conflicts detected"
        exit 0
    else
        number_conflicts=$(jq ".paginationContext.totalCount" <<< ${conflicts})
        echo "Number of conflicts detected: ${number_conflicts}"
        echo "Conflicts: ${conflicts}"
        exit 1
    fi

done
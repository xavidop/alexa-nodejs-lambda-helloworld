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
        conflicts=$(ask smapi get-conflicts-for-interaction-model -s ${skill_id} -l ${locale} -g development --vers ~current)
    fi

    number_conflicts=$(jq ".paginationContext.totalCount" <<< ${conflicts})

    if [[ -z ${number_conflicts} || ${number_conflicts} == "null" ]]
    then
        echo "No Conflicts detected"
        exit 0
    else
        echo "Number of conflicts detected: ${number_conflicts}"
        echo "Conflicts: ${conflicts}"
        exit 1
    fi

done
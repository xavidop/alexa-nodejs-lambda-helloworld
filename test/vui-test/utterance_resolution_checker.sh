#!/bin/bash
skill_id=$1

cli_version=$2

echo "######### Checking Utterance Resolutions #########"

if [[ ${cli_version} == *"v1"* ]]
then
    folder="../../models/*"
else
    folder="../../skill-package/interactionModels/*"
fi

for d in  ${folder}; do

    file_name="${d##*/}"
    locale="${file_name%.*}"

    echo "Checking Utterance resolution for locale: ${locale}"
    echo "###############################"

    while IFS="" read -r  utterance_to_test || [ -n "${utterance_to_test}" ]; do

        IFS=$'|' read -r -a utterance_to_test <<< "${utterance_to_test}"
        utterance=${utterance_to_test[0]}
        echo "Utterance to test: ${utterance}"
        expected_intent=${utterance_to_test[1]}
        #clean end of lines
        expected_intent=$(echo ${expected_intent} | sed -e 's/\r//g')

        echo "Expected intent: ${expected_intent}"

        if [[ ${cli_version} == *"v1"* ]]
        then
            resolution=$(ask api nlu-profile -s ${skill_id} -l ${locale} --utterance "${utterance}")
        else
            resolution=$(ask smapi profile-nlu -s ${skill_id} -l ${locale} --utterance "${utterance}" -g development)
        fi

        intent_resolved=$(jq ".selectedIntent.name" <<< ${resolution})

        echo "Intent resolved: ${intent_resolved}"

        if [[ ${intent_resolved} == *"${expected_intent}"* ]]
        then
            echo "No Utterance resolutions errors"
        else
            echo "Utterance resolution error"
            echo "Resolution: ${resolution}"
            exit 1
        fi

    done < "utterance_resolution/${locale}"

done
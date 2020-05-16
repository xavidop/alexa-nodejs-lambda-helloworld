# DevOps your Skill: VUI (Voice User Interface) Tests

According to the Wikipedia definition, "the Voice User Interface (VUI) enables human interaction with computers through a voice/speech platform to initiate automated processes or services. VUI is the interface of any speech application."

Thanks to machine learnig, big data, cloud and artificial intelligence we have managed to communicate with "computers" through the most natural way of communication of the human being: speech.

One of the most important steps in our pipeline is to test the VUI because is the frontend of our Alexa Skill.
These tests are automated in the continuous integration system (CircleCI) and are executed in each new version of the software.

## Prerequisites

Here you have the technologies used in this project
1. ASK CLI - [Install and configure ASK CLI](https://developer.amazon.com/es-ES/docs/alexa/smapi/quick-start-alexa-skills-kit-command-line-interface.html)
2. CircleCI Account - [Sign up here](https://circleci.com/)
3. Node.js v10.x
4. Visual Studio Code

## ASK CLI (Alexa Skill Kit CLI)

The Alexa Skills Kit Command Line Interface (ASK CLI) is a tool for you to manage your Alexa skills and related resources, such as AWS Lambda functions.
With ASK CLI, you have access to the Skill Management API, which allows you to manage Alexa skills programmatically from the command line.
We will use this powerful tool to test our Voice User Interface. Let's start!

### Installation

The ASK CLI is included in the [Docker image](https://hub.docker.com/repository/docker/xavidop/alexa-ask-aws-cli) we are using so it is not necessary to install anything else.

### Writing Tests

In this step of the pipeline we are going to develop some tests written in bash using the ASK CLI.

These tests are the following:

#### 1. Detect Utterance conflicts

Once we have uploaded the Alexa Skill in the `deploy` job, it is time to know if the interaction model we have uploaded has conflicts.

To know the conflicts, we will use the ASK CLI command:

1. For ask cli v1:
```bash
    ask api get-conflicts -s ${skill_id} -l ${locale}
```

2. For ask cli v2:
```bash
    ask smapi get-conflicts-for-interaction-model -s ${skill_id} -l ${locale} -g development --vers ~current
```

Those commands are integrated in the bash script file `test/vui-test/interaction_model_checker.sh`.

Here you can find the full bash script:

```bash
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
```

The test automatically detects the different interaction models of the skill and it checks their conflicts.
This script has two parameters:
1. The id of the skill
2. The version of the ASK CLI you are running (v1 or v2). 


#### 2. Test utterance resolutions

Now it is time to check the utterance resolution of our Voice User Interface.
Test your utterance resolutions with the utterance profiler as you build your interaction model. 
You can enter utterances and see how they resolve to the intents and slots. 
When an utterance does not invoke the right intent, you can update your sample utterances and retest, all before writing any code for your skill.

To run utterance resolutions, we will use the ASK CLI command:

1. For ask cli v1:
```bash
    ask api nlu-profile -s ${skill_id} -l ${locale} --utterance "${utterance}"
```

2. For ask cli v2:
```bash
    ask smapi profile-nlu -s ${skill_id} -l ${locale} --utterance "${utterance}" -g development
```

Those commands are integrated in the bash script file `test/vui-test/utterance_resolution_checker.sh`.

Here you can find the full bash script:

```bash
    #!/bin/bash
    skill_id=$1

    cli_version=$2

    echo "######### Checking Utterance Resolutions #########"

    if [[ ${cli_version} == *"v1"* ]]
    then
        folder="../models/*"
    else
        folder="../skill-package/interactionModels/*"
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
```

Additionally, we have a set of utterances and its expected intents depending on the locale. These set of utterances to tests are available in `test\utterance_resolution`. In our case, this is skill it is only available in Spanish so you can find in that folder the file `es-ES`:

```bash
    hola|HelloWorldIntent
    ayuda|AMAZON.HelpIntent 
```

As you can see, the format of this file is `Utterance|ExpectedIntent`. You can check the slot resolution but I did not do it in this example.

The test automatically detects the different interaction models of the skill and it checks the resolution of the utterances.
This script has two parameters:

1. The id of the skill
2. The version of the ASK CLI you are running (v1 or v2). 

#### 3. Evaluate and test our interaction 

To evaluate your model, you define a set of utterances mapped to the intents and slots you expect to be sent to your skill. This is called an annotation set. Then you start an NLU evaluation with the annotation set to determine how well your skill's model performs against your expectations. The tool can help you measure the accuracy of your NLU model, and run regression testing to ensure that changes to your model don't degrade the customer experience.

This test will be check the same that we have tested in the one described above but in a different way. In this test we are going to test the utterance resolution using annotations.

First of all, we have to create annotations in all locales that we have available our skill.

To know how to create an annotation check this [link](https://developer.amazon.com/en-US/docs/alexa/custom-skills/batch-test-your-nlu-model.html#create-annotations) from the official documentation.

When we have the annotations created, now we can check the utterance resolution using these annotations with the ASK CLI utterance evaluation commands.
This is an asynchronous process. so we have to start the evaluation with one command and then get the result with another when the evaluation is finished:

1. For ask cli v1:
```bash
    #start the evaluation
    id=ask api evaluate-nlu -a ${annotation} -s ${skill_id} -l ${locale}
    #get the results of the evaluation
    ask api get-nlu-evaluation -e ${id} -s ${skill_id}
```

2. For ask cli v2:
```bash
    #start the evaluation
    id=ask smapi create-nlu-evaluations --source-annotation-id ${annotation} -s ${skill_id} -l ${locale} -g development
    #get the results of the evaluation
    ask smapi get-nlu-evaluation --evaluation-id ${id} -s ${skill_id}
```

Those commands are integrated in the bash script file `test/vui-test/utterance_evaluation_checker.sh`.

Here you can find the full bash script:

```bash
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

```

Additionally, we have a set of annotations depending on the locale.
These set of annotations to tests are available in `test\utterance_evaluation`. In our case, this is skill it is only available in Spanish so you can find in that folder the file `es-ES`:

```bash
    bcdcd3d8-ed74-4751-bb9f-5d1a4d02259c
```

As you can see, this is the id of the annotation we have created in the Alexa Developer Console. If you have more than one, just add it in a new line.

The test automatically detects the different interaction models of the skill and it runs the evaluation for the annotations given.

This script has two parameters:
1. The id of the skill
2. The version of the ASK CLI you are running (v1 or v2). 

### Reports

There are not reports defined in this job.

### Integration

It is not necessary to integrate it in `package.json` file.

## Pipeline Jobs

Everything is ready to run and test our VUI, let's add it to our pipeline!

These 3 tests described above are defined in three different jobs that will run in parallel:

### 1. check-utterance-conflicts

This job will execute the following tasks:
1. Restore the code that we have downloaded in the previous step in `/home/node/project` folder
2. Run the `interaction_model_checker` script.

```yaml
  check-utterance-conflicts:
    executor: ask-executor
    steps:
      - attach_workspace:
          at: /home/node/
      - run: cd test/vui-test/ && ./interaction_model_checker.sh $SKILL_ID v1
```

### 2. check-utterance-resolution

This job will execute the following tasks:
1. Restore the code that we have downloaded in the previous step in `/home/node/project` folder
2. Run the `utterance_resolution_checker` script.

```yaml
  check-utterance-resolution:
    executor: ask-executor
    steps:
      - attach_workspace:
          at: /home/node/
      - run: cd test/vui-test/ && ./utterance_resolution_checker.sh $SKILL_ID v1
```

### 3. check-utterance-evaluation

This job will execute the following tasks:
1. Restore the code that we have downloaded in the previous step in `/home/node/project` folder
2. Run the `utterance_evaluation_checker` script.
3. Persist again the code that we will reuse in the next job

```yaml
  check-utterance-evaluation:
    executor: ask-executor
    steps:
      - attach_workspace:
          at: /home/node/
      - run: cd test/vui-test/ && ./utterance_evaluation_checker.sh $SKILL_ID v1
      - persist_to_workspace:
          root: /home/node/
          paths:
            - project
```

**NOTE:** To perform these tests in CircleCI you have to set the environment variable `SKILL_ID` with the id of your Alexa Skill.


## Resources
* [DevOps Wikipedia](https://en.wikipedia.org/wiki/DevOps) - Wikipedia reference
* [Official Alexa Skill Management API Documentation](https://developer.amazon.com/es-ES/docs/alexa/smapi/skill-testing-operations.html) - Alexa Skill Management API Documentation
* [Official CircleCI Documentation](https://circleci.com/docs/) - Official CircleCI Documentation

## Conclusion 

The VUI is our frontend and one of the most important things of our Alexa Skill. This is why these tests are very relevant in our pipeline.
Thanks to the ASK CLI we can perform this complex tests.

I hope this example project is useful to you.

That's all folks!

Happy coding!

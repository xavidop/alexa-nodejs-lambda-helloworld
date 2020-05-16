# DevOps your Skill: Validation Tests

There is another important step in an Alexa Skill development process. It is not related to the code or if the skill and its components are running porperly.
This step is the validation of our Alexa Skill before submitting it to certification. It means that the metadata of our Skill (logos, description, examples, etc) are properly filled. We can check it in our pipeline thanks to the ASK CLI and the use of the Alexa Skill Management API.

One of the most important steps in our pipeline is to validate our Alexa Skill.
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
We will use this powerful tool to validate our Alexa Skill. Let's start!

### Installation

The ASK CLI is included in the [Docker image](https://hub.docker.com/repository/docker/xavidop/alexa-ask-aws-cli) we are using so it is not necessary to install anything else.

### Writing the test

In this step of the pipeline we are going to develop some tests written in bash using the ASK CLI.

The Alexa Official documentation says that the Alexa Skill Validation API is an asynchronous API that can be used by skill developers to validate their skills before submitting them for certification or at any time during development as regression testing. A successful response may contain both successful and failed validation results. The Alexa Skill Validation API will also determine if a skill update qualifies for instant update to a live skill.

This is an asynchronous process. so we have to start the validation with one command and then get the result with another when the validation is finished:

1. For ask cli v1:
```bash
    #start the evaluation
    id=ask api validate-skill -s ${skill_id} -l ${locale}
    #get the results of the evaluation
    ask api get-validation -i ${id} -s ${skill_id}
```

2. For ask cli v2:
```bash
    #start the evaluation
    id=ask smapi submit-skill-validation -s ${skill_id} -l ${locale} -g developmentx
    #get the results of the evaluation
    ask smapi get-skill-validations --validation-id ${id} -s ${skill_id} -g development
```

Those commands are integrated in the bash script file `test/validation-test/skill_validation_checker.sh`.

Here you can find the full bash script:

```bash
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

```

The test automatically detects if the Alexa Skill is ready to submit to certification.

This script has two parameters:
1. The id of the skill
2. The version of the ASK CLI you are running (v1 or v2). 

### Reports

There are not reports defined in this job.

### Integration

It is not necessary to integrate it in `package.json` file.

## Pipeline Job

Everything is ready to run and validate our Alexa Skill, let's add it to our pipeline!

This job will execute the following tasks:
1. Restore the code that we have downloaded in the previous step in `/home/node/project` folder
2. Run the `skill_validation_checker` script.
3. Persist again the code that we will reuse in the next job

```yaml
  validation-test:
    executor: ask-executor
    steps:
      - attach_workspace:
          at: /home/node/
      - run: cd test/validation-test/ && ./skill_validation_checker.sh $SKILL_ID v1
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

We have to keep in mind this kind of tests. Despite we are not checking code here, this test will validate that our Alexa Skill will look really cool in the Skill Store so do not forget to run it. This is why these tests are very relevant in our pipeline.
Thanks to the ASK CLI we can perform this complex tests.

I hope this example project is useful to you.

That's all folks!

Happy coding!

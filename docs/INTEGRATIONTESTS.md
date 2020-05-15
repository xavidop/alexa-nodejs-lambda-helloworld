# DevOps your Skill: Integration Tests

Integration tests ensure that the components of an application is running properly at a level that includes the auxiliary infrastructure of the application, such as the voice user interface, the backend and the integration with external systems.

Integration tests evaluate the components of an application at a higher level than unit tests. 
Unit tests are used to test isolated software components, such as individual class methods. 
Integration tests check that two or more components of an application work together and they generate an expected result, possibly including all the components necessary to fully process a request.

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

The ASK CLI and the bash tool `expect` are included in the [Docker image](https://hub.docker.com/repository/docker/xavidop/alexa-ask-aws-cli) we are using so it is not necessary to install.

### Writing integration tests

In this step of the pipeline we are going to develop some tests written in bash using the ASK CLI.

Once we have tested our Voice User Interface and we check that everything is correct. It is time to test all software components related in an Alexa Skill request.

This integration tests can be performed with the ASK CLI. we will use the following ASK CLI command:

1. For ask cli v1 and v2:
```bash
    ask dialog -s ${skill_id} -l ${locale}
```

With this command we will perform a simulation of a dialog with our Alexa Skill using plaint text as input. So with that, we can test that all software components are running properly.

Those commands are integrated in the bash script file `test/integration-test/simple-dialog-checker.sh`.

Here you can find the full bash script:

```bash
    #!/usr/bin/expect

    set skill_id [lindex $argv 0];

    spawn ask dialog -s ${skill_id} -l es-ES
    expect "User"
    send -- "abre hola mundo\r"
    expect "Bienvenido, puedes decir Hola o Ayuda. Cual prefieres?"
    send -- "hola\r"
    expect "Hola Mundo!"
    send -- "abre hola mundo\r"
    expect "Bienvenido, puedes decir Hola o Ayuda. Cual prefieres?"
    send -- "ayuda\r"
    expect "Puedes decirme hola. Cómo te puedo ayudar?"
    send -- "adios\r"
    expect "Hasta luego!"

```

### Reports

There are not reports defined in this job.

### Integration

It is not necessary to integrate it in `package.json` file.

## Pipeline Job

It is ready to run our integration tests, let's add it to our pipeline!

This job will execute the following tasks:
1. Restore the code that we have downloaded in the previous step in `/home/node/project` folder
2. Run the `simple-dialog-checker` script.
3. Persist again the code that we will reuse in the next job

```yaml

  dialog:
    executor: ask-executor
    steps:
      - attach_workspace:
          at: /home/node/
      - run: cd test/integration-test/ && ./simple-dialog-checker.sh $SKILL_ID
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

Check that all components of our application are running properly is one of the most important things in every pipeline. 
These tests are used to test the application infrastructure and its components. This is why these tests are very relevant in our pipeline.
Thanks to the ASK CLI we can perform this complex tests.

You can write integration tests with Bespoken as well. See documentation [here](https://read.bespoken.io/end-to-end/guide/#overview). And set type test to `simulation` isntead of `e2e`


I hope this example project is useful to you.

That's all folks!

Happy coding!

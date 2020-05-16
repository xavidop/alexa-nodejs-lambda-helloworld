# DevOps your Skill: Deploy

When the code is checked in the previous steps, it is time to deploy the Skill to the Alexa cloud in order to start the next steps that will run different kind of tests. There are some tests like VUI tests, integrations tests, end-to-end tests and validation tests that we cannot run in localhost only with our code. This is why we need to deploy the Alexa Skill to the development stage.

These step are automated in the continuous integration system (CircleCI) and are executed in each new version of the software.

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

### Deploy

In this step of the pipeline we are going to deploy our Alexa Skill using the ASK CLI to the development stage.
When you deploy your skill to the development stage, it will update the skill manifest, interaction models, buckets, in-skill-purchasing products and lambda to the Alexa Cloud and AWS.
We can use the following commands in the ASK CLI to manage this deployment of our Alexa skill:

1. For ask cli v1:
```bash
    ask deploy --debug --force
```

2. For ask cli v2:
```bash
    ask deploy --debug --ignore-hash
```

### Reports

There are not reports defined in this job.

### Integration

It is not necessary to integrate it in `package.json` file.

## Pipeline Job

The deploy job will execute the following tasks:
1. Restore the code that we have used in the previous step in `/home/node/project` folder
2. Copy the `package.json` to `src/` folder.
3. Execute the `npm run build-production` command that will install only the production libraries in the `src/` folder.
4. Run `ask deploy --debug --force` that will deploy all the code in `src/` folder as an AWS lambda.
5. Persist again the code that we will reuse in the next job

```yaml
  deploy:
    executor: ask-executor
    steps:
      - attach_workspace:
          at: /home/node/
      - run: cd lambda/custom && npm run copy-package
      - run: cd lambda/custom/src && npm run build-production
      - run: ask deploy --debug --force
      - persist_to_workspace:
          root: /home/node/
          paths:
            - project
```
**NOTE:** If you want to run successfully every ASK CLI command, you have to set up 5 environment variables:

* `ASK_DEFAULT_PROFILE`
* `ASK_ACCESS_TOKEN`
* `ASK_REFRESH_TOKEN`
* `ASK_VENDOR_ID`
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

And configure the `__ENVIRONMENT_ASK_PROFILE__` profile in your `.ask/config` file.

How to obtain these variables and how to configure this profile are explained in [this post](https://dzone.com/articles/docker-image-for-ask-and-aws-cli-1)

## Resources
* [DevOps Wikipedia](https://en.wikipedia.org/wiki/DevOps) - Wikipedia reference
* [Official Alexa Skill Management API Documentation](https://developer.amazon.com/es-ES/docs/alexa/smapi/skill-testing-operations.html) - Alexa Skill Management API Documentation
* [Official CircleCI Documentation](https://circleci.com/docs/) - Official CircleCI Documentation

## Conclusion 

Thanks to the ASK CLI we can perform this complex task.

I hope this example project is useful to you.

That's all folks!

Happy coding!

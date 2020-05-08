'use strict';

/*
Mocha tests for the Alexa skill "Hello World" example (https://github.com/alexa/skill-sample-nodejs-hello-world).
Using the Alexa Skill Test Framework (https://github.com/BrianMacIntosh/alexa-skill-test-framework).
Run with 'mocha examples/skill-sample-nodejs-hello-world/helloworld-tests.js'.
*/

// include the testing framework
const alexaTest = require('alexa-skill-test-framework');
const languageStrings = require('../src/utilities/languageStrings.js');


// initialize the testing framework
alexaTest.initialize(
  require('../src/index.js'),
  'amzn1.ask.skill.00000000-0000-0000-0000-000000000000',
  'amzn1.ask.account.VOID');

alexaTest.initializeI18N(languageStrings);
alexaTest.setLocale('es-ES');

describe('Hello World Skill', function() {
  // tests the behavior of the skill's LaunchRequest
  describe('LaunchRequest', function() {
    alexaTest.test([
      {
        request: alexaTest.getLaunchRequest(),
        saysLike: alexaTest.t('WELCOME_MSG'), repromptsNothing: false, shouldEndSession: false,
      },
    ]);
  });

  // tests the behavior of the skill's HelloWorldIntent
  describe('HelloWorldIntent', function() {
    alexaTest.test([
      {
        request: alexaTest.getIntentRequest('HelloWorldIntent'),
        saysLike: alexaTest.t('HELLO_MSG'), repromptsNothing: true, shouldEndSession: true,
      },
    ]);
  });

  // tests the behavior of the skill's Help with like operator
  describe('AMAZON.HelpIntent', function() {
    alexaTest.test([
      {
        request: alexaTest.getIntentRequest('AMAZON.HelpIntent'),
        saysLike: alexaTest.t('HELP_MSG'), repromptsNothing: false, shouldEndSession: false,
      },
    ]);
  });

  describe('AMAZON.CancelIntent and AMAZON.CancelIntent', function(){
    alexaTest.test([
      { request: alexaTest.getIntentRequest('AMAZON.CancelIntent'),
        says: alexaTest.t('GOODBYE_MSG'), shouldEndSession: true },
      { request: alexaTest.getIntentRequest('AMAZON.CancelIntent'),
        says: alexaTest.t('GOODBYE_MSG'), shouldEndSession: true },
    ]);
  });

});

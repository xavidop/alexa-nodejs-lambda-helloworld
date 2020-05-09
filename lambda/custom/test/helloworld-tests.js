'use strict';

// include the testing framework
const test = require('ask-sdk-test');
const skillHandler = require('../src/index.js').handler;
// i18n strings for all supported locales
const languageStrings = require('../src/utilities/languageStrings.js');
const i18n = require('i18next');


// initialize the testing framework
const skillSettings = {
  appId: 'amzn1.ask.skill.00000000-0000-0000-0000-000000000000',
  userId: 'amzn1.ask.account.VOID',
  deviceId: 'amzn1.ask.device.VOID',
  locale: 'es-ES',
};

i18n.init({
  lng: skillSettings.locale,
  resources: languageStrings,
});

const alexaTest = new test.AlexaTest(skillHandler, skillSettings);

describe('Hello World Skill', function() {
  // tests the behavior of the skill's LaunchRequest
  describe('LaunchRequest', function() {
    alexaTest.test([
      {
        request: new test.LaunchRequestBuilder(skillSettings).build(),
        saysLike: i18n.t('WELCOME_MSG'), repromptsNothing: false, shouldEndSession: false,
      },
    ]);
  });

  // tests the behavior of the skill's HelloWorldIntent
  describe('HelloWorldIntent', function() {
    alexaTest.test([
      {
        request: new test.IntentRequestBuilder(skillSettings, 'HelloWorldIntent').build(),
        saysLike: i18n.t('HELLO_MSG'), repromptsNothing: true, shouldEndSession: true,
      },
    ]);
  });

  // tests the behavior of the skill's Help with like operator
  describe('AMAZON.HelpIntent', function() {
    alexaTest.test([
      {
        request: new test.IntentRequestBuilder(skillSettings, 'AMAZON.HelpIntent').build(),
        saysLike: i18n.t('HELP_MSG'), repromptsNothing: false, shouldEndSession: false,
      },
    ]);
  });

  describe('AMAZON.CancelIntent and AMAZON.CancelIntent', function(){
    alexaTest.test([
      { request: new test.IntentRequestBuilder(skillSettings, 'AMAZON.CancelIntent').build(),
        says: i18n.t('GOODBYE_MSG'), shouldEndSession: true },
      { request: new test.IntentRequestBuilder(skillSettings, 'AMAZON.CancelIntent').build(),
        says: i18n.t('GOODBYE_MSG'), shouldEndSession: true },
    ]);
  });

});

'use strict';

const Alexa = require('ask-sdk-core');
const i18n = require('i18next');


module.exports = {
  CancelAndStopIntentHandler: {
    canHandle(handlerInput) {
      return Alexa.getRequestType(handlerInput.requestEnvelope) === 'IntentRequest'
                && (Alexa.getIntentName(handlerInput.requestEnvelope) === 'AMAZON.CancelIntent'
                    || Alexa.getIntentName(handlerInput.requestEnvelope) === 'AMAZON.StopIntent');
    },
    handle(handlerInput) {
      const speakOutput = i18n.t('GOODBYE_MSG');

      return handlerInput.responseBuilder
        .speak(speakOutput)
        .getResponse();
    },
  },
};

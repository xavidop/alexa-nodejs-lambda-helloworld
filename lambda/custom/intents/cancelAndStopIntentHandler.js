const Alexa = require('ask-sdk-core');

module.exports = {
    CancelAndStopIntentHandler: {
        canHandle(handlerInput) {
            return Alexa.getRequestType(handlerInput.requestEnvelope) === 'IntentRequest'
                && (Alexa.getIntentName(handlerInput.requestEnvelope) === 'AMAZON.CancelIntent'
                    || Alexa.getIntentName(handlerInput.requestEnvelope) === 'AMAZON.StopIntent');
        },
        handle(handlerInput) {
            const speakOutput = handlerInput.t('GOODBYE_MSG');

            return handlerInput.responseBuilder
                .speak(speakOutput)
                .getResponse();
        }
    }
};
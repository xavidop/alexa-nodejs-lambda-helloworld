const Alexa = require('ask-sdk-core');

module.exports = {
    HelloWorldIntentHandler: {
        canHandle(handlerInput) {
            return Alexa.getRequestType(handlerInput.requestEnvelope) === 'IntentRequest'
                && Alexa.getIntentName(handlerInput.requestEnvelope) === 'HelloWorldIntent';
        },
        handle(handlerInput) {
            const speakOutput = handlerInput.t('HELLO_MSG');
    
            return handlerInput.responseBuilder
                .speak(speakOutput)
                //.reprompt('add a reprompt if you want to keep the session open for the user to respond')
                .getResponse();
        }
    }
};
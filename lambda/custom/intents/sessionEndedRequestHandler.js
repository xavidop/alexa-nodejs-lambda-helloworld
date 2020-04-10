const Alexa = require('ask-sdk-core');

/* *
 * SessionEndedRequest notifies that a session was ended. This handler will be triggered when a currently open 
 * session is closed for one of the following reasons: 1) The user says "exit" or "quit". 2) The user does not 
 * respond or says something that does not match an intent defined in your voice model. 3) An error occurs 
 * */
module.exports = {
    SessionEndedRequestHandler: {
        canHandle(handlerInput) {
            return Alexa.getRequestType(handlerInput.requestEnvelope) === 'SessionEndedRequest';
        },
        handle(handlerInput) {
            console.log(`~~~~ Session ended: ${JSON.stringify(handlerInput.requestEnvelope)}`);
            // Any cleanup logic goes here.
            return handlerInput.responseBuilder.getResponse(); // notice we send an empty response
        }
    }
};
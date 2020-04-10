const Alexa = require('ask-sdk-core');
// i18n library dependency, we use it below in a localisation interceptor
const i18n = require('i18next');
// i18n strings for all supported locales
const languageStrings = require('../utilities/languageStrings');

// This request interceptor will bind a translation function 't' to the handlerInput
module.exports = {
    LocalisationRequestInterceptor: {
        process(handlerInput) {
            i18n.init({
                lng: Alexa.getLocale(handlerInput.requestEnvelope),
                resources: languageStrings
            }).then((t) => {
                handlerInput.t = (...args) => t(...args);
            });
        }
    }
}
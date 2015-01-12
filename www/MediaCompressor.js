var exec = require('cordova/exec')
    , _interface = {
      compressAudio: function(originalSrc, successCallback, failCallback) {
        exec(successCallback, failCallback, 'MediaCompressor', 'compressAudio', [originalSrc]);
      }
      , compressVideo: function(originalSrc, successCallback, failCallback) {
        exec(successCallback, failCallback, 'MediaCompressor', 'compressVideo', [originalSrc]);
      };
    };

module.exports = _interface;
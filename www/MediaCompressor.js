var exec = require('cordova/exec')
    , _interface = {
      compressAudio: function(originalSrc, successCallback, failCallback) {
          if (typeof originalSrc === 'string' && originalSrc !== '') {
              originalSrc = originalSrc.replace('file://','');
              exec(successCallback, failCallback, 'MediaCompressor', 'compressAudio', [originalSrc]);
          }
      }
        , compressVideo: function(originalSrc, successCallback, failCallback) {
            if (typeof originalSrc === 'string' && originalSrc !== '') {
                originalSrc = originalSrc.replace('file://','');
                exec(successCallback, failCallback, 'MediaCompressor', 'compressVideo', [originalSrc]);
            }
        }
        , getVideoFrameSequence: function(videoSrc, successCallback, failCallback) {
            if (typeof videoSrc === 'string' && videoSrc !== '') {
                videoSrc = videoSrc.replace('file://','');
                exec(successCallback, failCallback, 'MediaCompressor', 'getVideoFrames', [videoSrc]);
            }
        }
    };

module.exports = _interface;
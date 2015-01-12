#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Cordova/CDV.h>

@interface MediaCompressor : CDVPlugin{
    NSString* callbackId;
}

@property (nonatomic, retain) NSString* callbackId;

- (void)compressAudio:(CDVInvokedUrlCommand *)command;
- (void)compressVideo:(CDVInvokedUrlCommand *)command;
@end

#import "MediaCompressor.h"

@implementation MediaCompressor

@synthesize callbackId;

- (void)compressAudio:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSString* audioPath = [command.arguments objectAtIndex:0];

    NSURL* audioURL = [NSURL fileURLWithPath:audioPath];
    AVURLAsset* audioAsset = [[AVURLAsset alloc] initWithURL:audioURL options:nil];
    AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:audioAsset presetName:AVAssetExportPresetAppleM4A];

    NSURL* destinationURL = [audioURL URLByAppendingPathExtension:@"mp4"];

    exportSession.outputURL = destinationURL;
    exportSession.outputFileType = AVFileTypeAppleM4A;

    NSLog(@"Arg URL=%@",audioPath);
    NSLog(@"Audio URL=%@",audioURL);
    NSLog(@"Destination URL=%@",destinationURL);
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    // remove file
    [fileMgr removeItemAtURL:destinationURL error:nil];

    [exportSession exportAsynchronouslyWithCompletionHandler:^{

        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            [self performSelectorOnMainThread:@selector(doSuccessCallback:) withObject:[exportSession.outputURL path] waitUntilDone:NO];
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
            NSLog(@"error: %@", exportSession.error);

            [self performSelectorOnMainThread:@selector(doFailCallback:) withObject:[NSString stringWithFormat:@"%li", exportSession.status] waitUntilDone:NO];

        } else {
            NSLog(@"Export Session Status: %ld", exportSession.status);
        }


        NSError *error;
        if ([fileMgr removeItemAtPath:audioPath error:&error] != YES) {
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
    }];
}

- (void)compressVideo:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSString* videoPath = [command.arguments objectAtIndex:0];
    
    NSURL* videoURL = [NSURL fileURLWithPath:videoPath];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPreset640x480];
    
    NSURL* destinationURL = [videoURL URLByAppendingPathExtension:@"mp4"];
    
    exportSession.outputURL = destinationURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    NSLog(@"Arg URL=%@",videoPath);
    NSLog(@"video URL=%@",videoURL);
    NSLog(@"Destination URL=%@",destinationURL);
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    // remove file
    [fileMgr removeItemAtURL:destinationURL error:nil];
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            [self performSelectorOnMainThread:@selector(doSuccessCallback:) withObject:[exportSession.outputURL path] waitUntilDone:NO];
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            NSLog(@"AVAssetExportSessionStatusFailed");
            NSLog(@"error: %@", exportSession.error);
            
            [self performSelectorOnMainThread:@selector(doFailCallback:) withObject:[NSString stringWithFormat:@"%li", exportSession.status] waitUntilDone:NO];
            
        } else {
            NSLog(@"Export Session Status: %ld", exportSession.status);
        }
        
        
        NSError *error;
        if ([fileMgr removeItemAtPath:videoPath error:&error] != YES) {
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
    }];
}

- (void)getVideoFrames:(CDVInvokedUrlCommand *)command
{
    self.callbackId = command.callbackId;
    NSString* videoPath = [command.arguments objectAtIndex:0];
    
    NSURL* videoURL = [NSURL fileURLWithPath:videoPath];
    AVURLAsset* videoAsset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    __block NSMutableArray* times = [[NSMutableArray alloc] init];
    for (float i = 0; i<CMTimeGetSeconds(videoAsset.duration); i++) {
        [times addObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(i, 600)]];
    }
    __block int imageCounter = 0, iterationCount = 0;
    __block NSMutableArray* savedImages = [[NSMutableArray alloc] init];
    
    AVAssetImageGenerator* imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:videoAsset];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
        iterationCount++;
        if (result == AVAssetImageGeneratorSucceeded) {
            NSString* targetDir = [videoPath stringByReplacingOccurrencesOfString:[videoURL lastPathComponent] withString:@""];
            NSString *savedImagePath = [targetDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%03d.png",[videoURL lastPathComponent],++imageCounter]];
            [savedImages addObject:savedImagePath];
            UIImage* imgOut = [[UIImage alloc] initWithCGImage:image];
            NSData *imageData = UIImagePNGRepresentation(imgOut);
            [imageData writeToFile:savedImagePath atomically:NO];
        }
        
        if (result == AVAssetImageGeneratorFailed) {
            
            NSLog(@"Failed with error: %@", [error localizedDescription]);
        }
        
        if (result == AVAssetImageGeneratorCancelled) {
            
            NSLog(@"Canceled");
            
        }
        if (iterationCount >= [times count]) {
            [self performSelectorOnMainThread:@selector(doSuccessImageFramesCallback:) withObject:savedImages waitUntilDone:NO];
        }
    }];
}

-(void) doSuccessImageFramesCallback:(NSArray*)paths {
    NSLog(@"doing success callback");
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:paths];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

-(void) doSuccessCallback:(NSString*)path {
    NSLog(@"doing success callback");

    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:path];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

-(void) doFailCallback:(NSString*)status {
    NSLog(@"doing fail callback");

    CDVPluginResult* pluginResult = nil;

    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end

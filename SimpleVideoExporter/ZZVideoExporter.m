//
//  ZZVideoExporter.m
//  SimpleVideoExporter
//
//  Created by zjj on 2019/10/16.
//  Copyright © 2019 zjj. All rights reserved.
//

#import "ZZVideoExporter.h"

@interface ZZVideoExporter()

@property (nonatomic, strong) NSString *inputPath;
@property (nonatomic, strong) NSString *outputPath;
@property (nonatomic, strong) AVAssetExportSession *exportSession;

@end

@implementation ZZVideoExporter

- (instancetype)initWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath usingHEVC:(BOOL)usingHEVC {
    self = [super init];
    self.inputPath = inputPath;
    self.outputPath = outputPath;
    
    AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.inputPath] options:nil];
    //    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:inputAsset];
    NSString *preset = usingHEVC ? AVAssetExportPresetHEVCHighestQuality : AVAssetExportPresetHighestQuality;
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:inputAsset presetName:preset];
    self.exportSession.outputURL = [NSURL fileURLWithPath:self.outputPath];
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    
    // 有些视频的宽高比是缩放的？旧系统会无法还原，然后压扁了
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:inputAsset];
    for (AVAssetTrack *track in inputAsset.tracks) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            NSArray *formatDescriptions = track.formatDescriptions;
            CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)formatDescriptions.firstObject;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            CFDictionaryRef cfdict = CMFormatDescriptionGetExtensions(desc);
            NSDictionary *nsdict = (__bridge id)cfdict;
            id pixcelAspectRatio = [nsdict valueForKey:@"CVPixelAspectRatio"];
            if (pixcelAspectRatio) {
                float horizontalSpacing = [[pixcelAspectRatio valueForKey:@"HorizontalSpacing"] floatValue];
                float verticalSpacing = [[pixcelAspectRatio valueForKey:@"VerticalSpacing"] floatValue];
                float width = dimensions.width;
                float height = dimensions.height;
                float radioSpacing = horizontalSpacing / verticalSpacing;
                width = width * radioSpacing;
                CGSize newSize = CGSizeMake((int)width, (int)height);
                videoComposition.renderSize = newSize;
            }
        }
    }
    //    videoComposition.renderSize = CGSizeMake(640, 480);
    self.exportSession.videoComposition = videoComposition;
    
    return self;
}

- (void)startExportWithCompletionHandler:(void (^)(void))handler {
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), handler);
    }];
}

- (void)cancel {
    [self.exportSession cancelExport];
}

#pragma mark getter

- (AVAssetExportSessionStatus)status {
    return self.exportSession.status;
}

- (float)progress {
    return self.exportSession.progress;
}

- (NSError *)error {
    return self.exportSession.error;
}

@end

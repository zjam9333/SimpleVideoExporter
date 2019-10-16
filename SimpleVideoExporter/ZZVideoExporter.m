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

- (instancetype)initWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath {
    self = [super init];
    self.inputPath = inputPath;
    self.outputPath = outputPath;
    
    AVURLAsset *inputAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.inputPath] options:nil];
    //    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:inputAsset];
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:inputAsset presetName:AVAssetExportPresetHighestQuality];
    self.exportSession.outputURL = [NSURL fileURLWithPath:self.outputPath];
    self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    return self;
}

- (void)startExport {
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        
    }];
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

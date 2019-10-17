//
//  ZZVideoExporter.h
//  SimpleVideoExporter
//
//  Created by zjj on 2019/10/16.
//  Copyright © 2019 zjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZZVideoExporter : NSObject

@property (nonatomic, readonly) NSString *inputPath;
@property (nonatomic, readonly) NSString *outputPath;

@property (nonatomic, readonly) AVAssetExportSessionStatus status;
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) NSError *error;

- (instancetype)initWithInputPath:(NSString *)inputPath outputPath:(NSString *)outputPath usingHEVC:(BOOL)usingHEVC;
- (void)startExportWithCompletionHandler:(void (^)(void))handler;
- (void)cancel;

@end

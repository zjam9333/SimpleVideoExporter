//
//  main.m
//  VideoExporter
//
//  Created by zjj on 2019/10/14.
//  Copyright © 2019 zjj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZVideoExporter.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *versionStr = @"1.0";
        printf("Hello World! Version %s\n", versionStr.UTF8String);
        if (argc < 3) {
            printf("usage: [apppath] [inputpath] [outputpath]\n");
            return 0;
        }
        NSString *inputPath = [NSString stringWithUTF8String:argv[1]];
        NSString *outputPath = [NSString stringWithUTF8String:argv[2]];
        
        printf("input:%s\n", inputPath.UTF8String);
        printf("output:%s\n", outputPath.UTF8String);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:inputPath]) {
            printf("input file does not exist: %s\n", inputPath.UTF8String);
            return 0;
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
            printf("file exists:%s, \nover write? [y/N] ", outputPath.UTF8String);
            char userInputChar = 0;
            scanf("%c", &userInputChar);
            if (userInputChar == 'y') {
                [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
            } else {
                printf("user canceled\n");
                return 0;
            }
        }
        
        ZZVideoExporter *exporter = [[ZZVideoExporter alloc] initWithInputPath:inputPath outputPath:outputPath usingHEVC:NO];
        [exporter startExportWithCompletionHandler:nil];
        
        float lastProgress = 0;
        int progressLinebreakCheck = 0;
        printf("starting...\n");
        while (1) {
//                typedef NS_ENUM(NSInteger, AVAssetExportSessionStatus) {
//                    AVAssetExportSessionStatusUnknown,
//                    AVAssetExportSessionStatusWaiting,
//                    AVAssetExportSessionStatusExporting,
//                    AVAssetExportSessionStatusCompleted,
//                    AVAssetExportSessionStatusFailed,
//                    AVAssetExportSessionStatusCancelled
//                };
            AVAssetExportSessionStatus status = exporter.status;
            BOOL stopped = status == AVAssetExportSessionStatusCancelled || status == AVAssetExportSessionStatusFailed || status == AVAssetExportSessionStatusCompleted;
            if (stopped) {
                printf("\n");
            }
            if (status == AVAssetExportSessionStatusExporting) {
                float progress = exporter.progress;
                float intProgress = ((float)(int)(progress * 10000)) / 100;
                if (intProgress != lastProgress) {
                    printf("%.2f%%,", intProgress);
                    fflush(stdout);
//                    usleep(100);
                    lastProgress = intProgress;
                    
                    progressLinebreakCheck ++;
                    if (progressLinebreakCheck > 10) {
                        progressLinebreakCheck = 0;
                        printf("\n");
                    }
                }
            }
            else if (status == AVAssetExportSessionStatusCompleted) {
                printf("export completed:%s\n", outputPath.UTF8String);
            }
            if (exporter.error) {
                printf("error:%s", exporter.error.description.UTF8String);
            }
            if (stopped) {
                break;
            }
        }
    }
    return 0;
}

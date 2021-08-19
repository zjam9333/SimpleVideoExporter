//
//  ViewController.m
//  SimpleVideoExporterApp
//
//  Created by zjj on 2019/10/16.
//  Copyright © 2019 zjj. All rights reserved.
//

#import "ZZExportQueueViewController.h"
#import "ZZDragFileView.h"
#import "ZZVideoExporter.h"

#define WeakDefine(strongA, weakA) __weak typeof(strongA) weakA = strongA;
#define tipsString @"将一个或多个mov或mp4文件拖入此窗口"

@interface ZZExportQueueViewController()<ZZDragFileViewDelegate, NSWindowDelegate>

@property (weak) IBOutlet NSTextField *outputPathTextField;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *tipsTextField;
@property (weak) IBOutlet NSTextView *queueTextView;
@property (weak) IBOutlet NSSegmentedControl *encodeSegment;

@property (strong, atomic) ZZVideoExporter *currentVideoExporter;
@property (strong, atomic) NSTimer *timer;
@property (strong, atomic) NSMutableArray<NSString *> *queuePathes;

@end

@implementation ZZExportQueueViewController

+ (void)showInNewWindow {
    NSWindowController *EditorWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"MyWindowController"];
    [EditorWC showWindow:nil];
}

- (void)dealloc {
    [self.currentVideoExporter cancel];
    NSLog(@"delloc: %@", self);
}

- (BOOL)windowShouldClose:(NSWindow *)sender {
    if (self.queuePathes.count > 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"返回"];
        [alert addButtonWithTitle:@"关闭"];
        [alert setInformativeText:@"队列正在进行中，关闭窗口吗"];
        [alert setAlertStyle:NSAlertStyleWarning];
        WeakDefine(self, weakself);
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertSecondButtonReturn) {
                [weakself.view.window close];
            }
        }];
        return NO;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 不再自动创建新窗口
//        [ZZExportQueueViewController showInNewWindow];
    });
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tipsTextField.stringValue = tipsString;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.view.window.delegate = self;
}

- (IBAction)selectOutputPath:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canCreateDirectories = YES;
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    panel.allowsMultipleSelection = NO;
    WeakDefine(self, weakself);
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSURL *first = panel.URLs.firstObject;
            weakself.outputPathTextField.stringValue = [self humanReadablePathString:first.absoluteString];
            if (weakself.queuePathes.count > 0) {
                [weakself tryStartQueue];
            }
        }
    }];
}

- (void)dragFileViewDidDragURLs:(NSArray *)URLs {
    
    NSMutableArray *decodePaths = [NSMutableArray array];
    for (NSURL *ur in URLs) {
        NSString *absStr = ur.absoluteString;
        absStr = [self humanReadablePathString:absStr];
        [decodePaths addObject:absStr];
    }
//    NSLog(@"%@", URLs);
    if (self.queuePathes.count == 0) {
        self.queuePathes = decodePaths;
        [self tryStartQueue];
    } else {
        [self.queuePathes addObjectsFromArray:decodePaths];
    }
    
    [self showCurrentQueue];
}

- (void)tryStartQueue {
    NSString *outputDir = self.outputPathTextField.stringValue;
    if (outputDir.length == 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setInformativeText:@"请选择目标文件夹"];
        [alert setAlertStyle:NSAlertStyleWarning];
        WeakDefine(self, weakself);
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            [weakself selectOutputPath:nil];
        }];
        return;
    }
    [self exportVideoForInputPath:self.queuePathes.firstObject];
}

- (NSString *)humanReadablePathString:(NSString *)pathString {
    pathString = [pathString stringByReplacingOccurrencesOfString:@"file:/" withString:@"/"];
    while ([pathString containsString:@"//"]) {
        pathString = [pathString stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    }
    pathString = [pathString stringByRemovingPercentEncoding];
    return pathString;
}

- (void)exportVideoForInputPath:(NSString *)inputPath {
    WeakDefine(self, weakself);
    // check output dir
    NSString *outputDir = self.outputPathTextField.stringValue ;
    if (outputDir.length == 0) {
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:outputDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:outputDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    // check input output path
    NSString *inputFileName = [[inputPath componentsSeparatedByString:@"/"] lastObject];
    NSString *outputFileName = [inputFileName stringByAppendingString:@".mp4"];
    NSString *outputPath = [outputDir stringByAppendingPathComponent:outputFileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        NSMutableArray *nameCompos = [[outputFileName componentsSeparatedByString:@"."] mutableCopy];
        if (nameCompos.count >= 2) {
            NSString *insertCompo = [NSString stringWithFormat:@"%ld.%ld", (long)[NSDate timeIntervalSinceReferenceDate] % 1000 , (long)arc4random() % 1000];
            [nameCompos insertObject:insertCompo atIndex:nameCompos.count - 1];
        }
        NSString *name = [nameCompos componentsJoinedByString:@"."];
        outputPath = [outputDir stringByAppendingPathComponent:name];
    }

    // check and show progress
    double timerInterval = 0.1;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timerInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        double currentProgress = weakself.currentVideoExporter.progress;
        // bar
        weakself.progressBar.doubleValue = currentProgress;
        weakself.tipsTextField.stringValue = [NSString stringWithFormat:@"正在导出：%@\n进度：%.2f%%", inputPath, currentProgress * 100];
    }];
    
    // init a exporter
    self.currentVideoExporter = [[ZZVideoExporter alloc] initWithInputPath:inputPath outputPath:outputPath usingHEVC:self.encodeSegment.selectedSegment == 1];
    
    [self.currentVideoExporter startExportWithCompletionHandler:^{
        [weakself.timer invalidate];
        weakself.progressBar.doubleValue = 0;
        NSError *err = weakself.currentVideoExporter.error;
        if (err) {
            weakself.tipsTextField.stringValue = err.description;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself completeWithInputPath:inputPath];
            });
            return;
        }
        if (weakself.currentVideoExporter.status == AVAssetExportSessionStatusCompleted) {
            weakself.progressBar.doubleValue = 1;
            weakself.tipsTextField.stringValue = [NSString stringWithFormat:@"已导出：%@", outputPath];
        }
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself completeWithInputPath:inputPath];
//        });
    }];
}

- (void)completeWithInputPath:(NSString *)inputPath {
    [self.queuePathes removeObject:inputPath];
    [self showCurrentQueue];
    if (self.queuePathes.count > 0) {
        // do next url
        [self exportVideoForInputPath:self.queuePathes.firstObject];
    }
}

- (void)showCurrentQueue {
    if (self.queuePathes.count > 0) {
        NSString *queueString = @"";
        for (NSString *path in self.queuePathes) {
            queueString = [NSString stringWithFormat:@"%@\n%@", queueString, path];
        }
        self.queueTextView.string = [NSString stringWithFormat:@"当前队列：%@", queueString];
    } else {
        self.queueTextView.string = @"";
        self.progressBar.doubleValue = 0;
        self.tipsTextField.stringValue = @"已完成全部队列，" tipsString;
    }
}

@end

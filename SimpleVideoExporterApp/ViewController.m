//
//  ViewController.m
//  SimpleVideoExporterApp
//
//  Created by zjj on 2019/10/16.
//  Copyright © 2019 zjj. All rights reserved.
//

#import "ViewController.h"
#import "ZZDragFileView.h"
#import "ZZVideoExporter.h"

#define WeakDefine(strongA, weakA) __weak typeof(strongA) weakA = strongA;

@interface ViewController()<ZZDragFileViewDelegate>

@property (weak) IBOutlet NSTextField *outputPathTextField;
@property (weak) IBOutlet NSProgressIndicator *progressBar;

@property ZZVideoExporter *currentVideoExporter;
@property NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
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
            NSString *path = first.absoluteString;
            weakself.outputPathTextField.stringValue = path;
        }
    }];
}

- (void)dragFileViewDidDragURLs:(NSArray *)URLs {
    NSLog(@"%@", URLs);
    [self exportVideoForInputURL:URLs.firstObject];
}

- (void)exportVideoForInputURL:(NSURL *)inputURL {
    if (!inputURL) {
        return;
    }
    WeakDefine(self, weakself);
    NSString *inputPath = [inputURL absoluteString];
    NSString *inputFileName = [[inputPath componentsSeparatedByString:@"/"] lastObject];
    NSString *outputPath = self.outputPathTextField.stringValue ;
    if (outputPath.length == 0) {
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    outputPath = [outputPath stringByAppendingPathComponent:inputFileName];
    self.currentVideoExporter = [[ZZVideoExporter alloc] initWithInputPath:inputPath outputPath:outputPath];
    [self.currentVideoExporter startExport];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"pro:%f", weakself.currentVideoExporter.progress);
        weakself.progressBar.doubleValue = weakself.currentVideoExporter.progress;
        if (weakself.currentVideoExporter.error) {
            NSLog(@"error: %@", weakself.currentVideoExporter.error);
            [timer invalidate];
        }
    }];
}

@end

//
//  AppDelegate.m
//  SimpleVideoExporterApp
//
//  Created by zjj on 2019/10/16.
//  Copyright © 2019 zjj. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)newDocument:(id)sender {
    NSWindowController *EditorWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialController];
    [EditorWC showWindow:nil];
}

@end

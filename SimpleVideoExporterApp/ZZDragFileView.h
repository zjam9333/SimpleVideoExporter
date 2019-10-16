//
//  MyView.h
//  SimpleVideoExporterApp
//
//  Created by zjj on 2019/10/16.
//  Copyright © 2019 zjj. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ZZDragFileViewDelegate <NSObject>

- (void)dragFileViewDidDragURLs:(NSArray *)URLs;

@end

@interface ZZDragFileView : NSView

@property (nonatomic, weak) IBOutlet id<ZZDragFileViewDelegate> delegate;

@end

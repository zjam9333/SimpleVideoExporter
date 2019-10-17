//
//  MyView.m
//  SimpleVideoExporterApp
//
//  Created by zjj on 2019/10/16.
//  Copyright © 2019 zjj. All rights reserved.
//

#import "ZZDragFileView.h"

@implementation ZZDragFileView

- (void)dealloc {
    [self unregisterDraggedTypes];
    NSLog(@"delloc: %@", self);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return [sender draggingSourceOperationMask];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSMutableArray *draggedURLs = [NSMutableArray array];
    NSArray *list = [pasteboard propertyListForType:NSFilenamesPboardType];
    for (NSString *str in list) {
        NSURL *url = [NSURL fileURLWithPath:str];
        [draggedURLs addObject:url];
    }
    if ([self.delegate respondsToSelector:@selector(dragFileViewDidDragURLs:)]) {
        [self.delegate dragFileViewDidDragURLs:draggedURLs];
    }
    return YES;
}

@end

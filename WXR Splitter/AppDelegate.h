//
//  AppDelegate.h
//  WXR Splitter
//
//  Created by Suhas Sharma on 26/08/12.
//  Copyright (c) 2012 Suhas Sharma. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    NSURL * outputDirec;
    NSArray * outputFile;

}
-(BOOL)splitProcess:(NSURL *)inputFile;
@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextField *sizeField;
- (IBAction)browseDirectory:(id)sender;
@property (assign) IBOutlet NSTextField *statusLabel;
- (IBAction)startSplitProcess:(id)sender;

@end

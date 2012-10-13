//
//  AppDelegate.m
//  WXR Splitter
//
//  Created by Suhas Sharma on 26/08/12.
//  Copyright (c) 2012 Suhas Sharma. All rights reserved.
//


#import "AppDelegate.h"

@implementation AppDelegate
@synthesize statusLabel;
@synthesize sizeField;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    outputDirec = nil;
    
    
}

-(BOOL)splitProcess:(NSURL *)inputFile {
    
    NSString * st = [NSString stringWithContentsOfURL:inputFile encoding:NSUTF8StringEncoding error:nil];
    if ([st rangeOfString:@"<channel>"].location == NSNotFound) {
        NSAlert* alert  = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Invalid WXR file."];
        [alert setInformativeText:@"We're not sure if this is a valid Wordpress WXR file. Please check."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:_window
                          modalDelegate:self didEndSelector:nil contextInfo:nil];
        
        return NO;
        
    }
    
    
    NSRange range = {0, [st rangeOfString:@"<item>"].location};
    NSString * xmlHeadPart = [st substringWithRange:range];
    unsigned long totalCount = [st length];
    unsigned long iteration = 0;
    unsigned long currentCount = 0;
    unsigned long maxInc = 1000000 * [sizeField intValue];
    BOOL EndOfFile = NO;
    NSURL *outputDirection = outputDirec;
    NSMutableArray * fileArray = [[NSMutableArray alloc] init];
    while (!EndOfFile) {
        NSString * fileName = [NSString stringWithFormat:@"%@_%lu.xml", [[inputFile lastPathComponent] stringByDeletingPathExtension], iteration];
        
        NSURL * currentFileName = [outputDirection URLByAppendingPathComponent:fileName];
      
            [fileArray addObject:currentFileName];
        
        if((currentCount+maxInc) < totalCount) {
            
            
            
            NSMutableString * fileContents = [NSMutableString stringWithString:xmlHeadPart];
            
            NSRange newRange = {currentCount,maxInc};
            NSString * xFile_i = [st substringWithRange:newRange];
            unsigned long itemL = 7;
            
            unsigned long incrFile = [xFile_i rangeOfString:@"</item>" options:NSBackwardsSearch].location + itemL;
            NSRange writeRange = {[xFile_i rangeOfString:@"<item>"].location,incrFile-[xFile_i rangeOfString:@"<item>"].location};
            [fileContents appendString:[xFile_i substringWithRange:writeRange]];
            currentCount += incrFile;
            [fileContents appendString:@"\n</channel>\n</rss>"];
            
            [fileContents writeToURL:currentFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
        } else {
            
            
            NSMutableString * fileContents = [NSMutableString stringWithString:xmlHeadPart];
            NSRange finalRange = {currentCount,(totalCount - currentCount)};
            NSString * xFile_i = [st substringWithRange:finalRange];
            [fileContents appendString:xFile_i];
            
            [fileContents writeToURL:currentFileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            EndOfFile = YES;
            [statusLabel setStringValue:[@"Finished processing " stringByAppendingString:[inputFile lastPathComponent]]];
        }
        
        iteration += 1;
        
        
    }
    
    outputFile = [NSArray arrayWithArray:fileArray];
    
    return YES;
}

- (IBAction)browseDirectory:(id)sender {
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:NO];
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result){
        if (result == NSOKButton) {
            outputDirec= [openPanel URL];
            
             [statusLabel setStringValue:[outputDirec path]];
            [openPanel orderOut:self];
            
            
        }
    }];
}
-(void)endProcess:(NSAlert *)alert returncode:(int)button contextInfo:(void *)context {
    
    
    if (button == NSAlertFirstButtonReturn) {
        
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:outputFile];
        
        
    }
    
    
    
}
- (IBAction)startSplitProcess:(id)sender {
    
    if (outputDirec != nil && [sizeField intValue] > 0) {
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"xml"]];
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result){
        if (result == NSOKButton) {
            
            [openPanel orderOut:self];
            if ([self splitProcess:[openPanel URL]]) {
                NSAlert* alert  = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"Take me there!"];
                [alert addButtonWithTitle:@"Ok, Whatever"];
                [alert setMessageText:@"Awesome!"];
                [alert setInformativeText:@"The file has been split successfully."];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(endProcess:returncode:contextInfo:) contextInfo:nil];

            }
            
            
            
        }
    }];
    } else {
        NSAlert* alert  = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:@"Please enter the appropriate information."];
        [alert setInformativeText:@"Make sure you've selected the Output Folder and set the Maximum filesize."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:_window
                        modalDelegate:self didEndSelector:nil contextInfo:nil];
        
    }
}
@end

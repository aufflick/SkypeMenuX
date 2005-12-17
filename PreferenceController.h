//
//  PreferenceController.h
//  SkypeMenuX
//
//  Created by Mark Aufflick on 13/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *startSkypeOnStartupKey;
extern NSString *hideSkypeOnStartupKey;

extern NSString *quitSkypeOnExitKey;
extern NSString *argvZero;

@interface PreferenceController : NSWindowController {
    
    IBOutlet NSButton *startSkypeMenuXOnLoginField;
    IBOutlet NSButton *hideSkypeOnLoginField;
    IBOutlet NSButton *startSkypeOnLoginField;
    
    IBOutlet NSButton *startSkypeOnStartupField;
    IBOutlet NSButton *hideSkypeOnStartupField;
    
    IBOutlet NSButton *quitSkypeOnExitField;
    
}

+(void)setArgvZero:(NSString*)arg;
+(NSString*)argvZero;
-(IBAction)changePrefs:(id)sender;
-(IBAction)startSkypeOnStartupClick:(id)sender;
-(void)readPrefs;
-(void)refresh;
-(NSString*)appBasename;
-(NSDictionary*)loginItemForBasename:appBasename;
-(void)updateHideSkypeButton;

@end

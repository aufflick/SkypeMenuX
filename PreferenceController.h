//
//  PreferenceController.h
//  SkypeMenuX
//
//  Created by Mark Aufflick on 13/12/05.
//  Copyright 2005 Mark Aufflick. All rights reserved.
//

/*
 Copyright © 2005, Mark Aufflick
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Mark Aufflick nor the names of contributors
 may be used to endorse or promote products derived from this
 software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 */

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

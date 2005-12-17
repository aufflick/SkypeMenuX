//
//  SkypeMenuController.h
//  SkypeMenu
//
//  Created by Mark Aufflick on 16/10/05.
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
#import <Skype/Skype.h>
@class AGRegex, AGRegexMatch;
@class AboutController;
@class PreferenceController;

@interface SkypeMenuController : NSObject <SkypeAPIDelegate> {
	
	// buddy username -> real name mapping
	NSMutableDictionary *buddyNames;
	// where we keep track of buddy online status by name
	NSMutableDictionary *buddyStatus;
	
	AGRegex *skypeFullnameRegex;
	
  //the status item that will be added to the system status bar
  NSStatusItem *statusItem;
	
  //the menu attached to the status item
  IBOutlet NSMenu *theMenu;

  // master array storing all the attributes of the various
  // skype userstatuses. See the structs below.
  id **userStatusDefs;

  // we use this regex a lot, so keep it handy
  AGRegex *skypeMessageSplit;

  // used to compare inbound notifications
  NSString *currentStatusToken;

  // sometimes we start skype in response to a status
  // menu action. skype takes a while to become available
  // so we queue the desired status in this var.
  NSString *queuedStatusChange;

  // images used by the status menu to indicate skype status
  NSImage *skypeIconOn;
  NSImage *skypeIconOff;

  // about window
  AboutController *aboutController;
  
  PreferenceController *preferenceController;
  
  // cache the bring skype to front applescript - used every time we chat
  NSAppleScript *bringSkypeToFrontScript;
  
  BOOL skypeShouldHideOnStartup;
  int skypeConnectRetries;
}

// manage skype status
-(IBAction)changeStatusMenuItem:(id)sender;

// util method used while building the menu
-(void)addStatusMenuItem:(int)statusIdx;

// bi-directional skype interaction methods
- (void)skypeSend:(NSString*)aSkypeCommand; // should return something
- (void)userstatusNotificationReceived:(NSArray*)tokens;
-(void)skypeProtocolNotificationReceived:(NSArray*)tokens;


- (void)tickStatusMenuItem:(int)itemIdx;

// open about window
-(IBAction)openAboutWindow:(id)sender;

// ref to various menus & items
-(NSMenu*)quitSubmenu;
-(NSMenuItem*)quitSkypeMenuItem;
-(NSMenuItem*)quitBothMenuItem;

// launch skype to the front
-(IBAction)activateSkypeMenuAction:(id)sender;
-(IBAction)quitSkypeMenuAction:(id)sender;
-(IBAction)quitBoth:(id)sender;
-(void)bringSkypeToFront;
-(void)quitSkype;
-(void)waitForSkype;
-(void)hideSkype;

-(void)toggleMenuSkypeConnected;
-(void)toggleMenuSkypeDisconnected;
-(void)releaseAboutController;

// handle buddy status changes
-(void)skypeBuddy:(NSString*)buddy statusString:(NSString*)status;
-(void)clearBuddyMenu;
-(void)skypeBuddyNotificationReceived:(NSArray*)tokens fullString:(NSString*)notificationString;
-(void)skypeBuddyListReceived:(NSArray*)tokens;
-(void)skypeReceivedBuddy:(NSString*)buddy fullnameNotification:(NSString*)notificationString;
-(void)updateStatusForBuddy:(NSString*)buddy;
-(void)updateBuddyMenu;
-(void)clearBuddyMenu;

-(NSString*)buddyNameFromSubmenuItem:(NSMenuItem*)item;
-(NSMenu*)makeChatSubmenu:(NSString*)fullname;


-(IBAction)openPrefs:(id)sender;

@end

// Skype USERSTATUS strings

/*Possible values:
UNKNOWN
ONLINE - current user is online
OFFLINE - current user is offline
SKYPEME - current user is in "Skype Me" mode (PROTOCOL 2).
AWAY - current user is away.
NA - current user is not available.
DND - current user is in "Do not disturb" mode.
INVISIBLE - current user is invisible to others.
LOGGEDOUT - current user is logged out. Clients are detached.*/

enum {
  USERSTATUS_UNKNOWN,
  USERSTATUS_ONLINE,
  USERSTATUS_OFFLINE,
  USERSTATUS_SKYPEME,
  USERSTATUS_AWAY,
  USERSTATUS_NA,
  USERSTATUS_DND,
  USERSTATUS_INVISIBLE,
  USERSTATUS_LOGGEDOUT
};

enum {
  USERSTATUS_SKYPE_STRING,
  USERSTATUS_DISPLAY,
  USERSTATUS_ONLINE_STATUS,
  USERSTATUS_AWAY_STATUS,
  USERSTATUS_REGEX,
  USERSTATUS_MENUITEM,
  USERSTATUS_IMAGE
};

//
//  SkypeMenuController.m
//  SkypeMenu
//
//  Created by Mark Aufflick on 16/10/05.
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


#import "SkypeMenuController.h"
#import "AppKit/NSMenuItem.h"
#import <AGRegex/AGRegex.h>;
#import "AboutController.h";

NSString* const myApplicationName = @"Skype Menu";
static const int N_USERSTATUS = 9;
static const int N_USERSTATUS_DEF_KEYS = 6;


@implementation SkypeMenuController

-(id)init
{
    self = [super init];

    queuedStatusChange = nil;

    // prepare array for storing the skype userstatus info
    userStatusDefs = malloc( sizeof(id**)  * N_USERSTATUS  );

    int i;
    for ( i=0 ; i  < N_USERSTATUS ; i++ ) {
        userStatusDefs[i] = malloc( sizeof(id*) * N_USERSTATUS_DEF_KEYS );

        // we will sometimes send messages via a loop - it's ok to message nil
        userStatusDefs[i][USERSTATUS_MENUITEM] = nil;
    }

    id *def;
    
    def = userStatusDefs[USERSTATUS_UNKNOWN];
    def[USERSTATUS_SKYPE_STRING]   = @"UNKNOWN";
    def[USERSTATUS_DISPLAY]        = @"Unknown";
    def[USERSTATUS_ONLINE_STATUS]  = @"OFFLINE";
    def[USERSTATUS_AWAY_STATUS]    = @"OFFLINE";
    def[USERSTATUS_REGEX]          = [[AGRegex alloc] initWithPattern:@"^UNKNOWN$"];

    def = userStatusDefs[USERSTATUS_ONLINE];
    def[USERSTATUS_SKYPE_STRING]    = @"ONLINE";
    def[USERSTATUS_DISPLAY]         = @"Online";
    def[USERSTATUS_ONLINE_STATUS]   = @"ONLINE";
    def[USERSTATUS_AWAY_STATUS]     = @"ONLINE";
    def[USERSTATUS_REGEX]           = [[AGRegex alloc] initWithPattern:@"^ONLINE$"];
	def[USERSTATUS_IMAGE]           = @"statusonline";
	
    def = userStatusDefs[USERSTATUS_OFFLINE];
    def[USERSTATUS_SKYPE_STRING]    = @"OFFLINE";
    def[USERSTATUS_DISPLAY]         = @"Offline";
    def[USERSTATUS_ONLINE_STATUS]   = @"OFFLINE";
    def[USERSTATUS_AWAY_STATUS]     = @"OFFLINE";
    def[USERSTATUS_REGEX]           = [[AGRegex alloc] initWithPattern:@"^OFFLINE$"];
	def[USERSTATUS_IMAGE]          = @"statusoffline";
	
    def = userStatusDefs[USERSTATUS_SKYPEME];
    def[USERSTATUS_SKYPE_STRING]    = @"SKYPEME";
    def[USERSTATUS_DISPLAY]         = @"Skype Me";
    def[USERSTATUS_ONLINE_STATUS]   = @"ONLINE";
    def[USERSTATUS_AWAY_STATUS]     = @"ONLINE";
    def[USERSTATUS_REGEX]           = [[AGRegex alloc] initWithPattern:@"^SKYPEME$"];
	def[USERSTATUS_IMAGE]          = @"statuschat";

    def = userStatusDefs[USERSTATUS_AWAY];
    def[USERSTATUS_SKYPE_STRING]    = @"AWAY";
    def[USERSTATUS_DISPLAY]         = @"Away";
    def[USERSTATUS_ONLINE_STATUS]   = @"ONLINE";
    def[USERSTATUS_AWAY_STATUS]     = @"AWAY";
    def[USERSTATUS_REGEX]           = [[AGRegex alloc] initWithPattern:@"^AWAY$"];
	def[USERSTATUS_IMAGE]          = @"statusaway";
	
    def = userStatusDefs[USERSTATUS_NA];
    def[USERSTATUS_SKYPE_STRING]    = @"NA";
    def[USERSTATUS_DISPLAY]         = @"Not Available";
    def[USERSTATUS_ONLINE_STATUS]   = @"ONLINE";
    def[USERSTATUS_AWAY_STATUS]     = @"AWAY";
    def[USERSTATUS_REGEX]           = [[AGRegex alloc] initWithPattern:@"^NA$"];
	def[USERSTATUS_IMAGE]          = @"statusnotavailable";
	
    def = userStatusDefs[USERSTATUS_DND];
    def[USERSTATUS_SKYPE_STRING]  = @"DND";
    def[USERSTATUS_DISPLAY]       = @"Do Not Disturb";
    def[USERSTATUS_ONLINE_STATUS] = @"ONLINE";
    def[USERSTATUS_AWAY_STATUS]   = @"AWAY";
    def[USERSTATUS_REGEX]         = [[AGRegex alloc] initWithPattern:@"^DND$"];
	def[USERSTATUS_IMAGE]          = @"statusdonotdisturb";
	
    def = userStatusDefs[USERSTATUS_INVISIBLE];
    def[USERSTATUS_SKYPE_STRING]   = @"INVISIBLE";
    def[USERSTATUS_DISPLAY]        = @"Invisible";
    def[USERSTATUS_ONLINE_STATUS]  = @"ONLINE";
    def[USERSTATUS_AWAY_STATUS]    = @"AWAY";
    def[USERSTATUS_REGEX]          = [[AGRegex alloc] initWithPattern:@"^INVISIBLE$"];
	def[USERSTATUS_IMAGE]          = @"statusinvisible";
	
    def = userStatusDefs[USERSTATUS_LOGGEDOUT];
    def[USERSTATUS_SKYPE_STRING]   = @"LOGGEDOUT";
    def[USERSTATUS_DISPLAY]        = @"Logged Out";
    def[USERSTATUS_ONLINE_STATUS]  = @"OFFLINE";
    def[USERSTATUS_AWAY_STATUS]    = @"OFFLINE";
    def[USERSTATUS_REGEX]          = [[AGRegex alloc] initWithPattern:@"^LOGGEDOUT$"];
	
    skypeMessageSplit = [[AGRegex alloc] initWithPattern:@" +"];
    
    return self;
}

- (void)awakeFromNib
{
    statusItem = [[[NSStatusBar systemStatusBar]
                      statusItemWithLength:NSSquareStatusItemLength] retain];
       
    [statusItem setHighlightMode:YES];

    skypeIconOn = [NSImage imageNamed:@"SkypeIcon"];
    skypeIconOff = [NSImage imageNamed:@"SkypeIconDisabled"];

    [statusItem setImage:skypeIconOff];
    [statusItem setAlternateImage:[NSImage imageNamed:@"SkypeIconHighlight"]];

    [statusItem setMenu:theMenu];
    [statusItem setEnabled:YES];


    // add an entry to the top of the menu for each userstatus
    int i;
    NSMenuItem *item;

    // one for offline
	[self addStatusMenuItem:USERSTATUS_OFFLINE];

    // a spacer
    [theMenu insertItem:[NSMenuItem separatorItem] atIndex:1];

    // now the away
    for ( i=N_USERSTATUS-1 ; i >= 0 ; i-- )
        if ( [userStatusDefs[i][USERSTATUS_AWAY_STATUS] isEqualToString:@"AWAY"] )
			[self addStatusMenuItem:i];
	
    // a spacer
    [theMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
   
    // now the online
    for ( i=N_USERSTATUS-1 ; i >= 0 ; i-- )
        if ( [userStatusDefs[i][USERSTATUS_AWAY_STATUS] isEqualToString:@"ONLINE"] )
			[self addStatusMenuItem:i];
	
	// disable the help entries & the skype quit entries
	[theMenu setAutoenablesItems: NO];
    [[theMenu itemAtIndex:0] setEnabled: NO]; // my status
	[[self quitSkypeMenuItem] setEnabled: NO]; // quit skype
	[[self quitBothMenuItem] setEnabled: NO]; // quit both
		

    [SkypeAPI setSkypeDelegate:self];
    
    [SkypeAPI connect];
    
}

-(void)addStatusMenuItem:(int)statusIdx
{
	NSMenuItem *item = [[NSMenuItem alloc]
						   initWithTitle:userStatusDefs[statusIdx][USERSTATUS_DISPLAY]
						   action:@selector(changeStatusMenuItem:)
						   keyEquivalent:@""];

	[item setTarget:self];
	if (userStatusDefs[USERSTATUS_IMAGE])
		[item setImage:[NSImage imageNamed:(NSString*)userStatusDefs[statusIdx][USERSTATUS_IMAGE]]];
	
	userStatusDefs[statusIdx][USERSTATUS_MENUITEM] = item;

	[theMenu insertItem:item atIndex:1];
}

// required delegate method
- (NSString*)clientApplicationName
{
    return myApplicationName;
}

-(IBAction)activateSkypeMenuAction:(id)sender
{
    [self bringSkypeToFront];
}

-(void)bringSkypeToFront
{
    NSAppleScript *script;
    script = [[NSAppleScript alloc] initWithSource:@"tell application \"Skype\" to activate"];
    [script executeAndReturnError:nil];
    [script release];
}

-(IBAction)quitSkypeMenuAction:(id)sender
{
    [self quitSkype];
}

-(void)quitSkype
{
    if (![SkypeAPI isSkypeRunning])
        return;
    NSAppleScript *script;
    script = [[NSAppleScript alloc] initWithSource:@"tell application \"Skype\" to quit"];
    [script executeAndReturnError:nil];
    [script release];
}

-(IBAction)quitBoth:(id)sender
{
    [self quitSkype];
    [[NSApplication sharedApplication] terminate:self];
}

-(IBAction)openAboutWindow:(id)sender
{
	NSLog(@"Opening about window");
		
	if( !aboutController )
		aboutController = [[AboutController alloc] init];
	
	[aboutController showAbout];
}

-(void)releaseAboutController
{
	[aboutController release];
}

-(void)setSkypeUserStatus:(NSString*)aSkypeStatusString
{
    // if skype is not running, start skype first via applescript
    // special case: if skype is not running, and desired state is offline, noop
    if (! [SkypeAPI isSkypeRunning] && ![aSkypeStatusString isEqualToString:@"OFFLINE"]) {
        [self bringSkypeToFront];
  
        // queue command in a variable which will be access by skype connect response available
        queuedStatusChange = aSkypeStatusString;
        [queuedStatusChange retain];
    } else {
        NSString* skypeCommandString = [NSString stringWithFormat:@"%@%@", @"SET USERSTATUS ", aSkypeStatusString];
    
        [self skypeSend:skypeCommandString];
    }
    [aSkypeStatusString release];
}

-(IBAction)changeStatusMenuItem:(id)sender
{
    // find the matching def
    int i;
    for ( i=0 ; i < N_USERSTATUS ; i++ ) {
        if ( [userStatusDefs[i][USERSTATUS_DISPLAY] isEqualToString:[sender title]] ) {
            [self setSkypeUserStatus:userStatusDefs[i][USERSTATUS_SKYPE_STRING]];
        }    
    }

}


// skype delegate
- (void)skypeBecameAvailable:(NSNotification*)aNotification
{
    NSLog(@"Skype became available");
	
	// toggle quit items
	[[self quitSkypeMenuItem] setEnabled:NO];
	[[self quitBothMenuItem] setEnabled:NO];

    [SkypeAPI connect];
    
    // if connected, the response will automatically update the menu appropriately
    [self skypeSend:@"GET USERSTATUS"];
}

- (void)toggleMenuSkypeConnected
{
    // also here fill in the available buddy list 
    
    [statusItem setImage:skypeIconOn];
	[[self quitSkypeMenuItem] setEnabled:YES];
	[[self quitBothMenuItem] setEnabled:YES];
}

-(NSMenuItem*)quitSkypeMenuItem
{
	return (NSMenuItem*)[theMenu itemAtIndex:N_USERSTATUS+6];
}

-(NSMenuItem*)quitBothMenuItem
{
	return (NSMenuItem*)[theMenu itemAtIndex:N_USERSTATUS+7];
}


// skype delegate
- (void)skypeBecameUnavailable:(NSNotification*)aNotification
{
    NSLog(@"Skype became UNavailable");
    // it's become unavailable - even if we didn't notice a disconnect notice, it really is disconnected!
    [self toggleMenuSkypeDisconnected];
	
	// disable quit items
	[[self quitSkypeMenuItem] setEnabled:NO];
	[[self quitBothMenuItem] setEnabled:NO];
}

- (void)toggleMenuSkypeDisconnected
{
    // also here clear the available buddy list
    [statusItem setImage:skypeIconOff];

    [self tickStatusMenuItem:-1];
    if (currentStatusToken != nil )
        [currentStatusToken release];
    currentStatusToken = nil;
}

- (void)makeSkypeGoOnline
{
    // if skype is not running, launch it
    // otherwise, just send a go online message
}

// skype delegate
- (void)skypeNotificationReceived:(NSString*)aNotificationString
{
    NSArray* notificationTokens = [skypeMessageSplit splitString:aNotificationString];
    
    NSString* token1 = [notificationTokens objectAtIndex:0];

    // switch out to differen methods
    if ( [token1 isEqualToString:@"USERSTATUS"] ) {
        // do i need to use a pool here for mem allocation?
        [self userstatusNotificationReceived: notificationTokens ];

    } else if ( [token1 isEqualToString:@"PROTOCOL"] ) {
        [self skypeProtocolNotificationReceived: notificationTokens ];

    } else {
        NSLog(@"Unknown Skype notification recieved: %@", aNotificationString);
    }
}

-(void)skypeProtocolNotificationReceived:(NSArray*)tokens
{
    // if the protocol is < 2 we should remove "skypeme" from the menu...
    NSLog(@"Skype notified us that we are using protocol: %@", [tokens objectAtIndex:1]);
}

- (void)tickStatusMenuItem:(int)itemIdx
{
    int i = 0;
    for (i = 0; i < N_USERSTATUS  ; i++) {
        if (i != itemIdx)
            [userStatusDefs[i][USERSTATUS_MENUITEM] setState:NSOffState];
    }
    if (itemIdx >= 0 && itemIdx < N_USERSTATUS)
        [userStatusDefs[itemIdx][USERSTATUS_MENUITEM] setState:NSOnState];

}

- (void)userstatusNotificationReceived:(NSArray*)tokens
{

    NSString *token = [tokens objectAtIndex:1];

    // do nothing if the current status hasn't changed
    if ([currentStatusToken isEqualToString:token])
        return;

    [token retain]; // not that memory allocation is being done properly anywhere else
    [currentStatusToken release];
    currentStatusToken = token;

    // loop through the statuses until we find the one that matches
    int i = 0;
    for (i = 0; i < N_USERSTATUS  ; i++) {

        if ( [[userStatusDefs[i][USERSTATUS_REGEX] findInString:token] count] == 1 ) {

            if ( [userStatusDefs[i][USERSTATUS_ONLINE_STATUS] isEqualToString: @"OFFLINE"] ) {
                i = USERSTATUS_OFFLINE; // collapse all offline notifs to one menu item
                [self toggleMenuSkypeDisconnected];
            }   else {
                // it's online, so we also need to set the user status in the menu
                [self toggleMenuSkypeConnected];
            }

            [self tickStatusMenuItem:i];

            break;
        }   
    }

}

// skype send
- (void)skypeSend:(NSString*)aSkypeCommand // should return something
{
    [SkypeAPI sendSkypeCommand:aSkypeCommand];
}

// skype delegate
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode
{
    switch (aAttachResponseCode)
    {
    case 0:
        NSLog(@"Failed to connect");
        break;
    case 1:
        NSLog(@"Skype sucessfully responded to our connection attempt");
            
        [self skypeSend:@"PROTOCOL 2"];
        if (queuedStatusChange != nil) {
            [self setSkypeUserStatus:queuedStatusChange];
            [queuedStatusChange release];
            queuedStatusChange = nil;
        } else
            [self skypeSend:@"GET USERSTATUS"];
        break;
    default:
        NSLog(@"Unknown response from Skype in response to our connection attempt");
        break;
    }
    
}



-(void)dealloc
{
    [statusItem release];
    
    // free the (wrongly capitalised) userstatusdef structs
    int i;
    for ( i=0 ; i < N_USERSTATUS ; i++ ) {
        [userStatusDefs[i][USERSTATUS_REGEX] release];
        free(userStatusDefs[i]);
    }
    free(userStatusDefs);

    [skypeMessageSplit release];

    if (currentStatusToken != nil)
        [currentStatusToken release];

    if (queuedStatusChange != nil)
        [queuedStatusChange release];

    [SkypeAPI disconnect];
    
    [super dealloc];
}

@end

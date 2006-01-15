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
#import "PreferenceController.h";

NSString* const myApplicationName = @"SkypeMenuX";
static const int N_USERSTATUS = 9;
static const int N_USERSTATUS_DEF_KEYS = 6;


@implementation SkypeMenuController

-(id)init
{
    self = [super init];

    queuedStatusChange = nil;

    // prepare array for storing the skype userstatus info
    userStatusDefs = malloc( (sizeof(id**)  * N_USERSTATUS)  );

    int i;
    for ( i=0 ; i  < N_USERSTATUS ; i++ ) {
        userStatusDefs[i] = malloc( sizeof(id*) * (N_USERSTATUS_DEF_KEYS+1) ); // why is the +1 necessary to pass malloc debug?

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
	
	skypeFullnameRegex = [[AGRegex alloc] initWithPattern:@"FULLNAME (.*)$"];
	
	buddyNames = [[NSMutableDictionary alloc] initWithCapacity:10];
	buddyStatus = [[NSMutableDictionary alloc] initWithCapacity:10];
		
    return self;
}

-(void)initialize
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    [defaultValues setObject:[NSNumber numberWithBool:NO] forKey: startSkypeOnStartupKey];
    [defaultValues setObject:[NSNumber numberWithBool:NO] forKey: hideSkypeOnStartupKey];
        
    [defaultValues setObject:[NSNumber numberWithBool:NO] forKey: quitSkypeOnExitKey];
            
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

- (void)awakeFromNib
{
    // start skype if necessary
    if ([[NSUserDefaults standardUserDefaults] boolForKey:startSkypeOnStartupKey]) {
        if (![SkypeAPI isSkypeRunning]) {
            [self bringSkypeToFront];
            // skype is piggy about letting us connect while it is starting and once
            // we've had a failed attempt it blocks us forever!
            //[self waitForSkype];
        }
    }
    
    //can't reliably  tell skype to hide while it is starting up
    if ([[NSUserDefaults standardUserDefaults] boolForKey:hideSkypeOnStartupKey]) {
        skypeShouldHideOnStartup = YES;
        [self hideSkype];
    }
    
    
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
	[[self quitSubmenu] setAutoenablesItems: NO];
    //[[theMenu itemAtIndex:0] setEnabled: NO]; // my status - handled by auto enable
	[[self quitSkypeMenuItem] setEnabled: NO]; // quit skype
	[[self quitBothMenuItem] setEnabled: NO]; // quit both

    [SkypeAPI setSkypeDelegate:self];
    
    if ([SkypeAPI isSkypeRunning]) {
        [SkypeAPI connect];
    }
    
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
    [[NSWorkspace sharedWorkspace] launchApplication:@"Skype"];
}

-(void)waitForSkype
{
    
    // send command  \"\" script name \"SkypeMenuX\"
    //NSAppleScript *waitForSkypeScript = [[NSAppleScript alloc] initWithSource:@"tell application \"Skype\" \n  count windows \n    end tell"];
    //int waitTries = 0;
    //NSString *response;
    //while(
      //    (
        //   (response = [[waitForSkypeScript executeAndReturnError:nil] stringValue]) == nil
          //  || ![response isEqualTo:@"2"]
           //)
         //&& waitTries++ < 4
        //)
        sleep(10); // this is so crap
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

-(void)hideSkype
{
    // don't do a is running test here - trust that our callers know what they are doing
    NSLog(@"hiding Skype");
    NSAppleScript *script;
    script = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"\n set visible of process \"Skype\" to false \n end tell"];
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
    
    // hide it if we should
    if (skypeShouldHideOnStartup) {
        [self hideSkype];
        skypeShouldHideOnStartup = NO;
    }
	
	// toggle quit items
	[[self quitSkypeMenuItem] setEnabled:NO];
	[[self quitBothMenuItem] setEnabled:NO];
    
    skypeConnectRetries = 0;
    [SkypeAPI connect];
	// auto connect things are done in attachResponse
}

- (void)toggleMenuSkypeConnected
{
    // also here fill in the available buddy list 
    
    [statusItem setImage:skypeIconOn];
	[[self quitSkypeMenuItem] setEnabled:YES];
	[[self quitBothMenuItem] setEnabled:YES];
}

-(int)buddyMenuStartIndex
{
	return N_USERSTATUS + 3;
}

-(NSMenu*)quitSubmenu
{
	NSEnumerator *enumerator = [[theMenu itemArray] objectEnumerator];
	NSMenuItem *item;
	while( (item=[enumerator nextObject]) )
		if([[item title] isEqualToString:@"Quit"] && [item hasSubmenu])
			return [item submenu];

	NSLog(@"Quit submenu not found");
	return nil;
}

-(NSMenuItem*)quitSkypeMenuItem
{
	return (NSMenuItem*)[[self quitSubmenu] itemAtIndex:0];
}

-(NSMenuItem*)quitBothMenuItem
{
	return (NSMenuItem*)[[self quitSubmenu] itemAtIndex:4];
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
	
	[self clearBuddyMenu];
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
    if ( [token1 isEqualToString:@"USERSTATUS"] )
        // do i need to use a pool here for mem allocation?
        [self userstatusNotificationReceived: notificationTokens ];

	else if ( [token1 isEqualToString:@"PROTOCOL"] ) 
        [self skypeProtocolNotificationReceived: notificationTokens ];
		
	else if ( [token1 isEqualToString:@"USER"] ) 
		[self skypeBuddyNotificationReceived: notificationTokens fullString:aNotificationString];

	else if ( [token1 isEqualToString:@"USERS"] )
		[self skypeBuddyListReceived: notificationTokens];

	else 
		NSLog(@"Unknown Skype notification recieved: %@", aNotificationString);

}

-(void)skypeProtocolNotificationReceived:(NSArray*)tokens
{
    // if the protocol is < 2 we should remove "skypeme" from the menu...
    NSLog(@"Skype notified us that we are using protocol: %@", [tokens objectAtIndex:1]);
}

-(void)skypeBuddyNotificationReceived:(NSArray*)tokens fullString:(NSString*)notificationString
{
	NSString *token1 = [tokens objectAtIndex:1];
	NSString *token2 = [tokens objectAtIndex:2];
		
	if ([token2 isEqualToString:@"ONLINESTATUS"])
		[self skypeBuddy:token1 statusString:[tokens objectAtIndex:3]];

	else if ([token2 isEqualToString:@"FULLNAME"])
		[self skypeReceivedBuddy:token1 fullnameNotification:notificationString];
	
	else
		NSLog(@"Unknown buddy notification recieved: %@", tokens);
}

-(void)skypeBuddyListReceived:(NSArray*)tokens
{
	NSEnumerator *buddyEnum = [tokens objectEnumerator];
	[buddyEnum nextObject]; // ignore first token which is "USERS"
	
	NSString *buddy;
	NSCharacterSet *comma = [NSCharacterSet characterSetWithCharactersInString:@","];
	
	while ( (buddy = [[buddyEnum nextObject] stringByTrimmingCharactersInSet:comma]) ) {
		[self updateStatusForBuddy:buddy];
	}
}

-(void)updateStatusForBuddy:(NSString*)buddy
{
	// request their status
	[self skypeSend:[NSString stringWithFormat:@"GET USER %@ ONLINESTATUS", buddy]];
}

-(void)skypeReceivedBuddy:(NSString*)buddy fullnameNotification:(NSString*)notificationString
{
	NSString *match = [[skypeFullnameRegex findInString:notificationString] groupAtIndex:1];

	if ( ! match )
		NSLog(@"No match found in buddy (%@) FULLNAME notification: %@", buddy, notificationString);
	else {
		NSLog(@"fullname for buddy (%@) is '%@'", buddy, match);
		[buddyNames setValue:match forKey:buddy];
		
		// if they are in the current menu, refresh it
		if ( [buddyStatus objectForKey:buddy] )
			[self updateBuddyMenu];
	}
}

-(void)skypeBuddy:(NSString*)buddy statusString:(NSString*)statusString
{
	NSLog(@"Buddy (%@) now has status (%@)", buddy, statusString);

	// using nil since that will cause setValue:forKey to remove the entry
	NSNumber *status = nil;
	
	// for now, we're assuming that the online/away/offline judgement is the
	// same for buddies as for our own userstatus
	int i = 0;
    for (i = 0; i < N_USERSTATUS  ; i++) {
		
        if ( [[userStatusDefs[i][USERSTATUS_REGEX] findInString:statusString] count] == 1 ) {
			
            if ( [userStatusDefs[i][USERSTATUS_AWAY_STATUS] isEqualToString: @"ONLINE"] ) {
                status = [NSNumber numberWithBool:YES];
				break;
			}
		} 
	}
	
	[buddyStatus setValue:status forKey:buddy];
	
	// make sure we know their fullname
	if (![buddyNames objectForKey:buddy]) 
		// request it
		[self skypeSend:[NSString stringWithFormat:@"GET USER %@ FULLNAME", buddy]];
	
	// now update the menu
	[self updateBuddyMenu];

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

    [token retain];
    [currentStatusToken release];
    currentStatusToken = token;

    // loop through the statuses until we find the one that matches
    int i = 0;
    for (i = 0; i < N_USERSTATUS  ; i++) {

        if ( [[userStatusDefs[i][USERSTATUS_REGEX] findInString:token] count] == 1 ) {

            if ( [userStatusDefs[i][USERSTATUS_ONLINE_STATUS] isEqualToString: @"OFFLINE"] ) {
                i = USERSTATUS_OFFLINE; // collapse all offline notifs to one menu item
                [self toggleMenuSkypeDisconnected];
            }   else
                // it's online, so we also need to set the user status in the menu
                [self toggleMenuSkypeConnected];

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
        
        // retry 3 times
        // doesn't help
        /*if (skypeConnectRetries < 4) {
            skypeConnectRetries++;
            sleep(2 * skypeConnectRetries);
            [SkypeAPI removeSkypeDelegate];
            [SkypeAPI setSkypeDelegate:self];
            [SkypeAPI connect];
        }*/
        break;
    case 1:
        NSLog(@"Skype sucessfully responded to our connection attempt");
            
        [self skypeSend:@"PROTOCOL 2"];
        if (queuedStatusChange != nil) {
            [self setSkypeUserStatus:queuedStatusChange];
            [queuedStatusChange release];
            queuedStatusChange = nil;
        } else {
            [self skypeSend:@"GET USERSTATUS"];
			[self skypeSend:@"SEARCH FRIENDS"];
		}
        break;
    default:
        NSLog(@"Unknown response from Skype in response to our connection attempt");
        break;
    }
    
    // butthe app IS running, so we can quit it
    // toggle quit items
    [[self quitSkypeMenuItem] setEnabled:NO];
    [[self quitBothMenuItem] setEnabled:NO];        
    
    
}


-(void)updateBuddyMenu
{
	NSLog(@"about to clear & update buddy menu");
	
	// it seems like the skype api makes a thread to call back from
	// hard to tell, since the api docs are a little thin
	
	// should use a proper mutex object here
	@synchronized( NSStringFromSelector(_cmd)) {

		[self clearBuddyMenu];
	
		NSLog(@"updating buddy menu");
		
		// the dictionary can change from under us - which would triger a beyond bounds exception
		NSDictionary *buddyStatusCopy = [NSDictionary dictionaryWithDictionary:buddyStatus];
			
		
		// should really be sorted by display name, but that is a bit trickier...
		NSArray *sortedBuddies = [[buddyStatusCopy allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
		// need the reverse of the sorted array since we are pushing them into the same index location
		NSEnumerator *buddyEnum = [sortedBuddies reverseObjectEnumerator];
	
		int itemIndex = [self buddyMenuStartIndex];
		NSMenuItem *item;
		NSString *buddy;
	
		if ( [buddyStatusCopy count] == 0 ) {
			NSLog(@"No buddies available");
			item = [[NSMenuItem alloc]
			       initWithTitle:@"None Available"
				   action:nil
				   keyEquivalent:@""];
		
			[item setImage:[NSImage imageNamed:@"buddyMenuImage"]];
		
			[theMenu insertItem:item atIndex:itemIndex];
		} else {
			NSLog(@"%d buddies available", [buddyStatusCopy count]);
				
			while ( (buddy=[buddyEnum nextObject]) ) {
				NSLog(@"Adding buddy to menu : %@", buddy);
				NSString *fullname = [buddyNames objectForKey:buddy];
				fullname = fullname == nil || [fullname isEqualToString:@""] ? buddy : fullname; // some people don't set their fullname property
			
				NSLog(@"fullname is : %@", fullname);
				item = [[NSMenuItem alloc]
				       initWithTitle:fullname
					   action:nil
					   keyEquivalent:@""];
			
				[item setImage:[NSImage imageNamed:@"buddyMenuImage"]];
				[item setSubmenu:[self makeChatSubmenu:fullname]];
				[item setTarget: self];
			
				[theMenu insertItem:item atIndex:itemIndex];
			}
		}
	}

}

-(NSMenu*)makeChatSubmenu:(NSString*)fullname
{
	NSMenu *buddySubmenu;
	
	// setup the sub menu that will hang off buddy status items
	buddySubmenu = [[NSMenu alloc] init];
	NSMenuItem *chatItem;
	
	// is there any way to find out what capabilities a particular buddy has?
    
    // if the menu is always going to be the same we can maybe just use one menu object
    // certainly we can clone rather than building

	chatItem = [[NSMenuItem alloc] initWithTitle:@"Text Chat" action:@selector(buddyMenuTextChat:) keyEquivalent:@""];
	[chatItem setTarget: self];
    [chatItem setImage: [NSImage imageNamed:@"text_chat"]];
	[buddySubmenu addItem:chatItem];
	
	chatItem = [[NSMenuItem alloc] initWithTitle:@"Voice Chat" action:@selector(buddyMenuVoiceChat:) keyEquivalent:@""];
	[chatItem setTarget: self];
    [chatItem setImage: [NSImage imageNamed:@"voice_chat"]];
	[buddySubmenu addItem:chatItem];
	
	return buddySubmenu;
}

-(void)clearBuddyMenu
{
	
	NSLog(@"about to clear buddy menu");
	@synchronized( NSStringFromSelector(_cmd)) {
		NSLog(@"clearing buddy menu");
		NSMenuItem *item;
		NSEnumerator *enumerator = [[theMenu itemArray] objectEnumerator];

		while( (item=[enumerator nextObject]) )
			if( ([item submenu] != nil && ![[item title] isEqualToString:@"Quit"])
			|| [[item title] isEqualToString:@"None Available"]){
				[theMenu removeItem:item];
				if ([item submenu])
					[[item submenu] release];
				[item release];
			}
	}
}

-(NSString*)buddyNameFromSubmenuItem:(NSMenuItem*)item
{
	// get the title of the item whose submenu was used
	int buddyItemIndex = [theMenu indexOfItemWithSubmenu:[item menu]];
	NSString *fullname = [[theMenu itemAtIndex:buddyItemIndex] title];
	NSLog(@"Buddy selected: %@", [item title]);
	
	NSEnumerator *buddyEnum = [buddyNames keyEnumerator];
	NSString *buddy;
	BOOL found = NO;

	while( (buddy = [buddyEnum nextObject]) ) {
		if ([[buddyNames objectForKey:buddy] isEqualToString:fullname]) {
			found = YES;
			NSLog(@"found budd name (%@) for fullname (%@)", buddy, fullname);
			break;
		} else
			NSLog(@"name from array (%@) is not who we're looking for (%@)", [buddyNames objectForKey:buddy], fullname);
	}

	if ( ! found ) {
		// if no entry matches against the fullname, it must be the buddy username itself (and the user hasn't set a fullname)
		NSLog(@"Defaulting to menu display name for buddyname: %@", fullname);
		buddy = fullname;
		// should check that this contains no spaces - i assume a buddy username can't comtain spaces?
	}

	return buddy;
}


-(IBAction)buddyMenuTextChat:(id)sender
{
	NSString *buddy = [self buddyNameFromSubmenuItem: sender];
	NSLog(@"got buddy string '%@' from buddyNameFromSubmenuItem", buddy);
	
	NSString *talkCommand = [NSString stringWithFormat:@"OPEN IM %@", buddy];
	
	[self skypeSend:talkCommand];
	[self bringSkypeToFront];
}

-(IBAction)buddyMenuVoiceChat:(id)sender
{
	NSString *buddy = [self buddyNameFromSubmenuItem: sender];
	NSLog(@"got buddy string '%@' from buddyNameFromSubmenuItem", buddy);
	
	NSString *talkCommand = [NSString stringWithFormat:@"CALL %@", buddy];
	
	[self skypeSend:talkCommand];
	[self bringSkypeToFront];
}

-(IBAction)openPrefs:(id)sender 
{ 
    NSLog(@"opening prefs"); 
    if(!preferenceController) 
        preferenceController=[[PreferenceController alloc] init];
    else
        [preferenceController refresh];
    
    [NSApp activateIgnoringOtherApps:YES]; 
    [[preferenceController window] makeKeyAndOrderFront:nil]; 
} 

-(void)dealloc
{
    // quit skype if necessary - should be somewhere else?
    if ([[NSUserDefaults standardUserDefaults] boolForKey:quitSkypeOnExitKey])
        [self quitSkype];
    
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

//
//  PreferenceController.m
//  SkypeMenuX
//
//  Created by Mark Aufflick on 13/12/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"
#import <AGRegex/AGRegex.h>

NSString *startSkypeOnStartupKey = @"Start Skype on startup";
NSString *hideSkypeOnStartupKey = @"Hide Skype on startup";

NSString *quitSkypeOnExitKey = @"Quit Skype on exit";
NSString *argvZero;

#define MAGICAUTOOPENKEYWORD    @"AutoLaunchedApplicationDictionary"
#define HIDEKEY            @"Hide"
#define PATHKEY            @"Path"


@implementation PreferenceController

+(void)setArgvZero:(NSString*)arg
{
    NSLog(@"argv[0] is %@", arg);
    argvZero = [arg retain];
}

+(NSString*)argvZero
{
    return argvZero;
}

-(id)init {
    if (self=[super initWithWindowNibName:@"Preferences"])
        [self setWindowFrameAutosaveName:@"PrefWindow"];
    
    return self;
}

-(void)windowDidLoad
{
    [self readPrefs];
    [self refresh];
}

// somewhat poorly named - reads all the prefs about login items
// seperate to readPrefs because we read this every time the preferences menu option is chosen in case the user has used the login items control panel or the start at login pref of skype
-(void)refresh {
    
    [startSkypeMenuXOnLoginField setState: [self loginItemForBasename:[self appBasename]] ? NSOnState : NSOffState];
    
    NSDictionary *skypeLoginItem = [self loginItemForBasename:@"Skype.app"];
    if (skypeLoginItem) {
        [startSkypeOnLoginField setState: NSOnState];
        if ([[skypeLoginItem objectForKey:HIDEKEY] boolValue])
            [hideSkypeOnLoginField setState: NSOnState];
        else
            [hideSkypeOnLoginField setState: NSOffState];
            
    } else {
        [startSkypeOnLoginField setState: NSOffState];        
    }
    [self updateHideSkypeButton];
}

-(NSArray*)loginItems
{
    NSString            *loginwindow = @"loginwindow";
    
    NSUserDefaults        *userDef;
    NSDictionary    *dict;
    NSArray        *loginItems;
    
    userDef = [[NSUserDefaults alloc] init];
    [userDef synchronize]; // make sure we see changes immediately
    
    if( !(dict = [userDef persistentDomainForName:loginwindow]) )
        return nil;
    
    if( !(loginItems = [dict objectForKey:MAGICAUTOOPENKEYWORD]) )
        return nil;
    
    [userDef release];
    
    return loginItems;
}

// replaces all current login items with the list provided
-(void)setLoginItems:(NSArray*)newLoginItems
{
    NSString            *loginwindow = @"loginwindow";
    
    NSUserDefaults        *userDef;
    NSMutableDictionary    *dict;
    
    userDef = [[NSUserDefaults alloc] init];
    
    if( !(dict = [[userDef persistentDomainForName:loginwindow] mutableCopyWithZone: NULL]) )
        dict = [[NSMutableDictionary alloc] initWithCapacity:1];

    /* update user defaults */
    
    [dict setObject:newLoginItems forKey:MAGICAUTOOPENKEYWORD];
        
    [userDef removePersistentDomainForName:loginwindow];
    [userDef setPersistentDomain:dict forName:loginwindow];
    [userDef synchronize];
    
    /* clean up */
    
    [dict release];
    [userDef release];
    
}

-(NSString*)appBasename
{
    AGRegex *appPathRe = [[AGRegex alloc] initWithPattern:@"^(.*)/([^/]+\\.app)"];
    return [[appPathRe findInString:[PreferenceController argvZero]] groupAtIndex:2];
}

-(NSString*)appFullPathForString:(NSString*)path {
    AGRegex *appPathRe = [[AGRegex alloc] initWithPattern:@"^(.*\\.app)"];
    return [[appPathRe findInString:path] groupAtIndex:1];
}

-(NSString*)appFullPath {
    return [self appFullPathForString:[PreferenceController argvZero]];
}

-(NSString*)skypeFullPath {
    NSAppleScript *getSkypePathScript = [[NSAppleScript alloc] initWithSource:@"POSIX path of (path to application \"Skype\")"];
    NSString *skypePath = [[getSkypePathScript executeAndReturnError:nil] stringValue];
    [getSkypePathScript release];
    
    // seems to come with a trailing slash
    return [self appFullPathForString:skypePath];
}

-(NSString*)appPath {
    AGRegex *appPathRe = [[AGRegex alloc] initWithPattern:@"^(.*)/([^/]+\\.app)"];
    return [[appPathRe findInString:[PreferenceController argvZero]] groupAtIndex:1];
}

-(NSDictionary*)loginItemForBasename:appBasename {
    
    NSArray *loginItems = [self loginItems];

    
    AGRegex *skmxRe = [[AGRegex alloc] initWithPattern:[NSString stringWithFormat:@"/%@", appBasename]];
    
    // see if any of the current login items match our basename
    NSEnumerator *loginItemEnumerator = [loginItems objectEnumerator];
    NSDictionary *loginItem;
    while (loginItem = [loginItemEnumerator nextObject]) {
        NSString *path = [loginItem objectForKey:PATHKEY];
        if ([skmxRe findInString:path]) {
            return loginItem;
        }
    }
    return nil;
}

-(void)readPrefs
{
    // Values read from prefs
    int hideSkype = [[NSUserDefaults standardUserDefaults] boolForKey:hideSkypeOnStartupKey] ? NSOnState : NSOffState;
    [hideSkypeOnStartupField setState:hideSkype];
    
    int startSkype = [[NSUserDefaults standardUserDefaults] boolForKey:startSkypeOnStartupKey] ? NSOnState : NSOffState;
    [startSkypeOnStartupField setState:startSkype];
    
    int quitSkype = [[NSUserDefaults standardUserDefaults] boolForKey:quitSkypeOnExitKey] ? NSOnState : NSOffState;
    [quitSkypeOnExitField setState:quitSkype];
    
}

-(IBAction)changePrefs:(id)sender
{
    NSLog(@"Saving Prefs");
    
    // Values saved to prefs
    
    BOOL startSkype = [startSkypeOnStartupField state] == NSOnState ? YES : NO;
    [[NSUserDefaults standardUserDefaults] setBool:startSkype forKey:startSkypeOnStartupKey];
    
    BOOL hideSkype = [hideSkypeOnStartupField state] == NSOnState ? YES : NO;
    [[NSUserDefaults standardUserDefaults] setBool:hideSkype forKey:hideSkypeOnStartupKey];
    

    // Values that are saved to their source
    NSArray *originalLoginItems = [self loginItems];
    NSMutableArray *mutableLoginItems = [originalLoginItems mutableCopyWithZone:NULL];
    
    // start skypemenux on login
    BOOL startSkmxOnLogin = [startSkypeMenuXOnLoginField state] == NSOnState ? YES : NO;
    NSDictionary *startSkmxLoginItem = [self loginItemForBasename:[self appBasename]];
    
    if (startSkmxOnLogin && ! startSkmxLoginItem) {
        NSLog(@"add skmx to login items");
        // add skmx to login items
                
        NSDictionary        *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithBool:NO], HIDEKEY,
            [self appFullPath], PATHKEY,
            nil];
        
        [mutableLoginItems insertObject:tempDict atIndex:0];
        [tempDict release];
        
    } else if (! startSkmxOnLogin && startSkmxLoginItem) {
        NSLog(@"remove skmx from login items");

        [mutableLoginItems removeObject:startSkmxLoginItem];
    }
    
    // start skype on login
    BOOL startSkypeOnLogin = [startSkypeOnLoginField state] == NSOnState ? YES : NO;
    BOOL hideSkypeOnLogin = [hideSkypeOnLoginField state] == NSOnState ? YES : NO;
    NSDictionary *startSkypeLoginItem = [self loginItemForBasename:@"Skype.app"];
    
    if (! startSkypeOnLogin && startSkypeLoginItem) {
        NSLog(@"remove skype from login items");
        // can ingnore hide pref in this case
        
        [mutableLoginItems removeObject:startSkypeLoginItem];
        
    } else if (startSkypeOnLogin && ! startSkypeLoginItem) {
        NSLog(@"add skype to login items");
        
        NSNumber *hideObject;
        if (hideSkypeOnLogin) {
            NSLog(@"when we add it, hide will be on");
            hideObject = [NSNumber numberWithBool:YES];
        } else {
            NSLog(@"when we add it, hide will be off");
            hideObject = [NSNumber numberWithBool:NO];
        }
        
        NSDictionary        *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:
            hideObject, HIDEKEY,
            [self skypeFullPath], PATHKEY,
            nil];
        
        [mutableLoginItems insertObject:tempDict atIndex:0];
        [tempDict release];
        
    } else if (startSkypeOnLogin && startSkypeLoginItem) {
        NSLog(@"skype is already in the login items");
        
        BOOL existingLoginItemHidden = [[startSkypeLoginItem objectForKey:HIDEKEY] boolValue];
        NSNumber *newHideObject = nil;
        
        if (hideSkypeOnLogin && ! existingLoginItemHidden) {
            NSLog(@"need to set hide flag on existing skype login item");
            newHideObject = [NSNumber numberWithBool:YES];
            
        } else if (!hideSkypeOnLogin && existingLoginItemHidden) {
            NSLog(@"need to unset hide flag on existing skype login item");
            newHideObject = [NSNumber numberWithBool:NO];
        
        }
        
        if (newHideObject) {
            NSMutableDictionary *mutableStartSkypeLoginItem = [startSkypeLoginItem mutableCopyWithZone:NULL];
            [mutableStartSkypeLoginItem setObject:newHideObject forKey:HIDEKEY];
            
            [mutableLoginItems replaceObjectAtIndex:[mutableLoginItems indexOfObject:startSkypeLoginItem] withObject:mutableStartSkypeLoginItem];
        }
    }
    
    if (![mutableLoginItems isEqualTo:originalLoginItems]) {
        NSLog(@"saving changes to login items");
        [self setLoginItems:mutableLoginItems];
    }
    [mutableLoginItems autorelease];
    
    [[self window] performClose:nil];
}

-(IBAction)startSkypeOnStartupClick:(id)sender
{
    [self updateHideSkypeButton];
}

-(void)updateHideSkypeButton {
    if ([startSkypeOnLoginField state] == NSOnState)
        [hideSkypeOnLoginField setEnabled: YES];
    else if ([startSkypeOnLoginField state] == NSOffState) {
        [hideSkypeOnLoginField setState: NSOffState];
        [hideSkypeOnLoginField setEnabled: NO];
    }
}

-(void)windowWillClose:(NSNotification *)aNotification
{
    [startSkypeMenuXOnLoginField abortEditing];
    [startSkypeOnLoginField abortEditing];
    [hideSkypeOnLoginField abortEditing];
    
    [startSkypeOnStartupField abortEditing];
    [hideSkypeOnStartupField abortEditing];
    
    [quitSkypeOnExitField abortEditing];
    
    [self readPrefs];
}

@end

/*
 
 Copyright 2003-2006 P-Edge Media
 Copyright 2006-2010 Damage Studios, LLC.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 (or the full text of the license is below)
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
*/

#import "MainController.h"
#import "define.h"
#import "messages.h"

@implementation MainController

- (IBAction)paypalDonate:(id)sender
{
    // launch the URL for donating through paypal
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:PAYPAL_DONATE_URL]];
}

- (IBAction)launchHelpURL:(id)sender
{
    // launch the URL for the online manual
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:ONLINE_MANUAL_URL]];
}

- (IBAction)checkForUpdate:(id)sender
// check for online updates
{
    NSString *currAppName = GSC_APPNAME; // the name of this app
    NSString *currVersionNumber = GSC_VERSION; // the version of this app

    // get the version info from the web
    NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:
        [NSURL URLWithString:VERSION_CHECK_URL]];
    NSString *latestVersionNumber = [productVersionDict valueForKey:VERSIONDICTKEY];

    if (latestVersionNumber == nil) { // no xml file could be found
        NSBeep();
        NSRunAlertPanel(ALE_NOUPDATECHECK1, ALE_NOUPDATECHECK2, ALE_ILLCHECKLATER, nil, nil);
    } else {
        if([latestVersionNumber isEqualToString: currVersionNumber]) { // software is up to date
            NSRunAlertPanel(ALE_NOUPDATEFOUND1, [NSString stringWithFormat: ALE_NOUPDATEFOUND2, currVersionNumber, currAppName], ALE_OKBUTTON, nil, nil);
        } else { // tell user to download a new version
            int button = NSRunAlertPanel(ALE_NEWVERSFOUND1, [NSString stringWithFormat: ALE_NEWVERSFOUND2, latestVersionNumber], ALE_YESBUTTON, ALE_NOBUTTON, nil);
            if (button == NSOKButton) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:DOWNLOAD_NEW_URL]];
            }
        }
    }
}

- (IBAction)showAboutBox:(id)sender
// this method shows the about box
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableString * versionText = [[NSMutableString alloc] initWithString: ABO_VERS];
    [versionText appendString:GSC_VERSION];
    [versionText appendString:@"\n"];
    [versionText appendString:COPYRIGHT_TEXT];

    [appTitle setStringValue:GSC_TITLE];
    [versionString setStringValue:versionText];
    [expiryString setStringValue:EXPIRY_DATE];
    [disclaimString setStringValue:ABOUT_DISCLAIM];

    // show the box
    [aboutBox center];
    [aboutBox makeKeyAndOrderFront:sender];
    
    [pool release];
}

- (IBAction)setSliderBars:(id)sender
// this method sets the sliders when a textbox is edited
{
    // network tab items
    if ([[maxPingLabel stringValue] length] == 0) { [maxPingLabel setStringValue:@"0"]; }
    [setMaxPing setIntValue:[maxPingLabel intValue]];
    if ([[maxPlayersLabel stringValue] length] == 0) { [maxPlayersLabel setStringValue:@"8"]; }
    [setMaxPlayers setIntValue:[maxPlayersLabel intValue]];
    if ([[maxReconnectLabel stringValue] length] == 0) { [maxReconnectLabel setStringValue:@"8"]; }
    [setMaxReconnect setIntValue:[maxReconnectLabel intValue]];
    if ([[minPingLabel stringValue] length] == 0) { [minPingLabel setStringValue:@"0"]; }
    [setMinPing setIntValue:[minPingLabel intValue]];
    if ([[netPortLabel stringValue] length] == 0) { [netPortLabel setStringValue:@"12203"]; }
    [setNetPort setIntValue:[netPortLabel intValue]];

    // server tab items
    if ([[joinTimeLabel stringValue] length] == 0) { [joinTimeLabel setStringValue:@"0"]; }
    [setJoinTime setIntValue:[joinTimeLabel intValue]];
    if ([[respwanTimeLabel stringValue] length] == 0) { [respwanTimeLabel setStringValue:@"15"]; }
    [setRespawnTime setIntValue:[respwanTimeLabel intValue]];
    if ([[spectateTimeLabel stringValue] length] == 0) { [spectateTimeLabel setStringValue:@"300"]; }
    [setSpectateTime setIntValue:[spectateTimeLabel intValue]];
    if ([[kickTimeLabel stringValue] length] == 0) { [kickTimeLabel setStringValue:@"300"]; }
    [setKickTime setIntValue:[kickTimeLabel intValue]];
    if ([[muteMessagesLabel stringValue] length] == 0) { [muteMessagesLabel setStringValue:@"4"]; }
    [setMuteMessages setIntValue:[muteMessagesLabel intValue]];
    if ([[unmuteTimeLabel stringValue] length] == 0) { [unmuteTimeLabel setStringValue:@"10"]; }
    [setUnmuteTime setIntValue:[unmuteTimeLabel intValue]];

    // game tab items
    if ([[fragLimitLabel stringValue] length] == 0) { [fragLimitLabel setStringValue:@"50"]; }
    [setFragLimit setIntValue:[fragLimitLabel intValue]];
    if ([[timeLimitLabel stringValue] length] == 0) { [timeLimitLabel setStringValue:@"15"]; }
    [setTimeLimit setIntValue:[timeLimitLabel intValue]];
    if ([[roundLimitLabel stringValue] length] == 0) { [roundLimitLabel setStringValue:@"15"]; }
    [setRoundLimit setIntValue:[roundLimitLabel intValue]];
    if ([[captureLimitLabel stringValue] length] == 0) { [captureLimitLabel setStringValue:@"10"]; }
    [setCaptureLimit setIntValue:[captureLimitLabel intValue]];
    
    if ([[teamKillWarn stringValue] length] == 0) { [teamKillWarn setStringValue:@"1"]; }
    if ([[teamKillKick stringValue] length] == 0) { [teamKillKick setStringValue:@"2"]; }
    if ([[gravityLabel stringValue] length] == 0) { [gravityLabel setStringValue:@"800"]; }
}

- (IBAction)checkGeneralFields:(id)sender
// checks the admin name, server name etc for invalid characters. Some characters are not allowed
{    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    // replace illegal chars with emtpy chars
    NSMutableString *temp = [[NSMutableString alloc] init];
    
    // modify servername
    [temp setString:[serverName stringValue]];
    [temp replaceOccurrencesOfString:@"?" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [serverName setStringValue:temp];
    
    // modify serverlocation
    [temp setString:[serverLocation stringValue]];
    [temp replaceOccurrencesOfString:@"?" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [serverLocation setStringValue:temp];
    
    // modify adminName
    [temp setString:[adminName stringValue]];
    [temp replaceOccurrencesOfString:@"?" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"&" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [temp length])];
    [adminName setStringValue:temp];
    
    // set the servername at the bottom of the screen
    [serverNameLabel setStringValue:[serverName stringValue]];
    
    [pool release];
}

- (IBAction)checkRconPass:(id)sender
// checks if rconpass is shorter than 6 characters
{
    if ([[setRconPass stringValue] length] < 6) {
        NSBeep();
        int button = NSRunAlertPanel(ALE_RCONPASS1, ALE_RCONPASS2, ALE_OKBUTTON, ALE_ONLINEHELP, nil);
        if (button == NSCancelButton) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_RCONPASS_URL]];
        }
    }
}

- (IBAction)checkServMess:(id)sender
{
    [self checkServMessNow];
}

- (void)checkServMessNow
// this method checks the server messages field for irregularities
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    if ([[servMessTime stringValue] length] == 0) { [servMessTime setStringValue:@"4"]; }
    if ([[servMessWait stringValue] length] == 0) { [servMessWait setStringValue:@"8"]; }
    if ([[servMessText stringValue] length] == 0) { [servMessText setStringValue:GEN_SERVMESSERR]; }
    
    NSArray *servMessLines = [[servMessText stringValue] componentsSeparatedByString:@"\n"]; // message lines
    if ([servMessLines count] > 0 ) { // there are lines
        NSMutableString *newServMess = [[NSMutableString alloc] init];
        NSMutableString *currentLine = [[NSMutableString alloc] init];
        NSEnumerator *e = [servMessLines objectEnumerator];
        NSNumber *cur;
        unsigned int c=0;
        
        while (cur = (NSNumber *)[e nextObject]) { // traverse the lines
            [currentLine setString:[servMessLines objectAtIndex:c++]];
            if ([currentLine length] > 0) { // there is something in the line
                [currentLine replaceOccurrencesOfString:@"://" withString:@":/ /" options:NSLiteralSearch range:NSMakeRange(0, [currentLine length])];
                [currentLine replaceOccurrencesOfString:@"Û" withString:@"EUR" options:NSLiteralSearch range:NSMakeRange(0, [currentLine length])];
                [currentLine replaceOccurrencesOfString:@"£" withString:@"GBP" options:NSLiteralSearch range:NSMakeRange(0, [currentLine length])];
                [currentLine replaceOccurrencesOfString:@"©" withString:@"(C)" options:NSLiteralSearch range:NSMakeRange(0, [currentLine length])];
                [currentLine replaceOccurrencesOfString:@"¨" withString:@"(R)" options:NSLiteralSearch range:NSMakeRange(0, [currentLine length])];
                [currentLine replaceOccurrencesOfString:@"ª" withString:@"(TM)" options:NSLiteralSearch range:NSMakeRange(0, [currentLine length])];
                [currentLine appendString:@"\n"];
                [newServMess appendString:currentLine];
            }
        }
        [servMessText setStringValue:newServMess];
    }
    [pool release];
}

- (void)updateApplicationBadge:(int)number
// this method displays a badge in the application's dock icon with the number in it.
// use zero to remove the badge, numbers over 40 will generate ">40" icon
{
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    NSImage *appImage, *newAppImage, *badge;
    NSSize newAppImageSize;
    
    // Grab the unmodified application image.
    appImage = [[NSImage alloc] initWithContentsOfFile:[thisBundle pathForResource:APPICONIMAGE ofType:@""]];
    
    // create the new image
    newAppImageSize = NSMakeSize(128, 128);
    newAppImage = [[NSImage alloc] initWithSize:newAppImageSize];
    
    // Draw into the new image (the badged image)
    [newAppImage lockFocus];
    
    // First draw the unmodified app image.
    [appImage drawInRect:NSMakeRect(0, 0, newAppImageSize.width, newAppImageSize.height)
                fromRect:NSMakeRect(0, 0, [appImage size].width, [appImage size].height)
               operation:NSCompositeCopy fraction:1.0];

    // Now draw the badge if the number is higher than 0.
    if (number > 0) {
        if (number <= 40) {
            badge = [[NSImage alloc] initWithContentsOfFile:[thisBundle pathForResource:[NSString stringWithFormat:@"badge%d.gif", number] ofType:@""]];
        } else {
            badge = [[NSImage alloc] initWithContentsOfFile:[thisBundle pathForResource:@"badge_over_40.gif" ofType:@""]];
        }
        [badge drawInRect:NSMakeRect(78, 4, 47, 48) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    }
    
    [newAppImage unlockFocus];
    
    // Set the new icon: a badged icon.
    [NSApp setApplicationIconImage:newAppImage];
    [newAppImage release];
}

- (void)checkForUpdate
// check for online updates at startup
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSString *currVersionNumber = GSC_VERSION; // the version of this app
    
    // get the version info from the web
    NSDictionary *productVersionDict = [NSDictionary dictionaryWithContentsOfURL:
        [NSURL URLWithString:VERSION_CHECK_URL]];
    NSString *latestVersionNumber = [productVersionDict valueForKey:VERSIONDICTKEY];
    
    if (latestVersionNumber != nil) { // an xml file could be found
        if(![latestVersionNumber isEqualToString: currVersionNumber]) { // there is a new version
            int button = NSRunAlertPanel(ALE_NEWVERSFOUND1, [NSString stringWithFormat: ALE_NEWVERSFOUND2, latestVersionNumber], ALE_YESBUTTON, ALE_NOBUTTON, nil);
            if (button == NSOKButton) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:DOWNLOAD_NEW_URL]];
            }
        }
    }
    
    [pool release];
}

@end
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

#import "LaunchController.h"
#import "MainController.h"
#import "DocController.h"
#import "define.h"
#import "messages.h"

@implementation LaunchController

- (void)awakeFromNib
{
    // don't know why this is here.
    [fileNewMenuItem setEnabled : YES];
    [fileOpenMenuItem setEnabled : YES];
}

- (IBAction)launchGame:(id)sender
{
    [self launchGameInit];
}

- (void)launchGameInit
// This method writes the config files and starts the launch thread.
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    BOOL gameProcessAlreadyRuns = [self gameProcessRuns];
    BOOL configSaved = NO; // check if config can be saved
    
    if (gameProcessAlreadyRuns) {
        NSBeep();
        int button = NSRunAlertPanel(ALE_CANNOTLAUNCH1, ALE_CANNOTLAUNCH2, ALE_OKBUTTON, ALE_ONLINEHELP, nil);
        if (button == NSCancelButton) { // they chose for online help
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: HELP_QUIT_FIRST_URL]];
        }
    }
    
    if (!gameIsRunning && !gameProcessAlreadyRuns) { // the game is not already running
        srand(time(NULL)); // set the randomizer
        [mainController checkServMessNow]; // correct the current server messages
    
        banListChanged = NO; // no-one is banned (yet)
        playerArray = [[NSMutableArray alloc] init];
    
        // set up the "change map" selection list
        [mapSelector removeAllItems];
        [mapSelector addItemWithTitle: MAN_SELECTMAP];
        [mapSelector addItemsWithTitles:[[availableMapList stringValue] componentsSeparatedByString:@" "]];
        [mapSelectorButton setEnabled: NO];

        // launch the game
        // NSLog(@"------------- LAUNCH-------------");
        [spinner startAnimation:self]; // start the progress indicator (spinner)
        [manSpinner setStyle:NSProgressIndicatorSpinningStyle];
        [manSpinner setDisplayedWhenStopped:NO];
        [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
        [statusMessage setStringValue: GEN_LAUNCHING]; // set statusmessage
        [launchButton setEnabled: NO]; // disable the launch button
    
        // check for bots versus players and set current amount of bots
        [self checkBotsValue];
        [manSetBotsLabel setIntValue:[botsLabel intValue]];

        // set menu items
        [launchMenuItem setEnabled : NO]; // disable the launch menu item
        [stopMenuItem setEnabled : YES]; // enable the stop menu item
        [fileNewMenuItem setEnabled : NO];
        [fileOpenMenuItem setEnabled : NO];
        [fileRecentMenuItem setEnabled: NO];
        [mapMenuItem setEnabled: NO];
        [talkMenuItem setEnabled: YES];
        [kickMenuItem setEnabled: YES];
        [banMenuItem setEnabled: YES];
        [quitMenuItem setEnabled: NO];
        [prefsMenuItem setEnabled: NO];
        [checkUpdateMenuItem setEnabled: NO];
    
        [manQuitButton setEnabled:YES]; // enable quit button
    
        // empty the console
        [theText replaceCharactersInRange:NSMakeRange(0, [[theText textStorage] length]) withString:CONSOLE_HEADER];

        // wait a second for dramatic effect
        [NSThread sleepUntilDate:[[NSDate date] addTimeInterval:1]];

        // creating and writing the server cfg file
        NSMutableString *filePath = [[NSMutableString alloc] initWithString:[[gameFolder stringValue] stringByAppendingString: CONFIGFILENAME]]; // set the filename

        NSMutableString *fileContents = [[NSMutableString alloc] init];
        [fileContents appendString:CONFIG_HEADER1];
        [fileContents appendString:CONFIG_HEADER2];
        
        // hard coded items
        [fileContents appendString:@"set developer 0\n"];
        [fileContents appendString:@"seta sv_allowDownload 0\n"];
        [fileContents appendString:@"seta sv_fps 20\n"];
        [fileContents appendString:@"seta ui_dedicated 2\n"];

        // general tab items
        [fileContents appendString:[NSString stringWithFormat:@"set sv_hostname \"%@\"\n", [serverName stringValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"sets \"Admin\" \"%@\"\n", [adminName stringValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"sets \"Admin E-Mail\" \"%@\"\n", [adminEmail stringValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"sets \"Location\" \"%@\"\n", [serverLocation stringValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"sets \"Hours\" \"%@\"\n", [serverHours stringValue]]];

        // network tab items
        [fileContents appendString:[NSString stringWithFormat:@"seta rconPassword \"%@\"\n", [setRconPass stringValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"set sv_maxclients %d\n", [setMaxPlayers intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta sv_maxPing %d\n", [setMaxPing intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta sv_minPing %d\n", [setMinPing intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta sv_reconnectlimit %d\n", [setMaxReconnect intValue]]];
        if ([isOnlineServer intValue] == 1) { // yes, online server
            [fileContents appendString:[NSString stringWithFormat:@"seta sv_gamespy %d\n", [setGameSpy intValue]]];
            [fileContents appendString:[NSString stringWithFormat:@"seta sv_master1 \"%@\"\n", [onlineServer1 stringValue]]];
            [fileContents appendString:[NSString stringWithFormat:@"seta sv_master2 \"%@\"\n", [onlineServer2 stringValue]]];
            [fileContents appendString:[NSString stringWithFormat:@"seta sv_master3 \"%@\"\n", [onlineServer3 stringValue]]];
            [fileContents appendString:@"seta sv_master4 \"\"\n"];
            [fileContents appendString:@"seta sv_master5 \"\"\n"];
        } else { // LAN server
            [fileContents appendString:@"seta sv_gamespy 0\n"];
            [fileContents appendString:@"seta sv_master1 \"\"\n"];
            [fileContents appendString:@"seta sv_master2 \"\"\n"];
            [fileContents appendString:@"seta sv_master3 \"\"\n"];
        }

        // server tab items
        [fileContents appendString:[NSString stringWithFormat:@"seta g_respawnInterval %d\n", [setRespawnTime intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_allowjointime %d\n", [setJoinTime intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_inactivity %d\n", [setSpectateTime intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_inactiveSpectate %d\n", [setSpectateTime intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_inactiveKick %d\n", [setKickTime intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta sv_flood_waitdelay %d\n", [setUnmuteTime intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta sv_flood_persecond %d\n", [setMuteMessages intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta sv_pure %d\n", [setDiffMapVersion intValue]]];

        // game tab items
        [fileContents appendString:[NSString stringWithFormat:@"set g_forceteamspectate %d\n", [setSpectateOwn intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_teamdamage %d\n", [setFriendlyFire intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_teamForceBalance %d\n", [setForceBalance intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"set fraglimit %d\n", [setFragLimit intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"set timelimit %d\n", [setTimeLimit intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"set roundlimit %d\n", [setRoundLimit intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"set capturelimit %d\n", [setCaptureLimit intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_allowvote %d\n", [setAllowVoting intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_teamkillwarn %d\n", [teamKillWarn intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_teamkillkick %d\n", [teamKillKick intValue]]];

        // various items
        [fileContents appendString:[NSString stringWithFormat:@"set bot_minplayers %d\n", [botsLabel intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"set cheats %d\n", [setAllowCheating intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"set sv_gravity %d\n", [setGravity intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_healthdrop %d\n", [dropHealthPack intValue]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta g_realismmode %d\n", [enableRealism intValue]]];

        // maps tab items
        [fileContents appendString:[NSString stringWithFormat:@"set g_gametype %d\n", [[gameType selectedItem] tag]]];
        [fileContents appendString:[NSString stringWithFormat:@"seta sv_maplist \"%@\"\n", [mapRotation stringValue]]];
        
        // other items
        NSArray *firstMapName = [[mapRotation stringValue] componentsSeparatedByString:@" "];
        [fileContents appendString:[NSString stringWithFormat:@"map \"%@\"\n", [firstMapName objectAtIndex:0]]];

        if (![fileContents writeToFile:filePath atomically:YES]) { // write the file
            NSBeep();
            int button = NSRunAlertPanel(ALE_CANNOTLAUNCH1, ALE_CANNOTLAUNCH3, ALE_OKBUTTON, ALE_ONLINEHELP, nil);
            if (button == NSCancelButton) { // they chose for online help
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: HELP_SAVE_FILES_URL]];
            }
        } else { // save is successful
            configSaved = YES;
        }
    }

    if (configSaved) { // file is saved OKAY! launch the server
        // set up the task launcher
        NSString *gameAppName = GAMEAPPNAME; // game app file

        NSString *currentFolder = [gameFolder stringValue]; // current gameFolder
        NSString *completeGamePath = [currentFolder stringByAppendingString : gameAppName]; // game folder path including filename
        NSMutableArray *arguments = [NSMutableArray array]; // set the arguments
        
        [arguments addObject:GAMEPARAMETER1];
        [arguments addObject:[NSString stringWithFormat:GAMEPARAMETER3, [setNetPort intValue]]];

        // see if it's an dedicated ONLINE server
        if ([isOnlineServer intValue] == 1) { // yes, online
           [arguments addObject:GAMEPARAMETER2];
        }
        
        // show the managementwindow
        [manServerName setStringValue:[serverName stringValue]]; // set servername
        [manServerStatus setStringValue:GEN_LAUNCHING]; // set statusmessage
        [manServerStatus setTextColor: [NSColor blueColor]]; // set statuscolor
        [self showManagementWindow]; // open the management window
        
        // here we are going to submit this server (signon) to the main GSC Server list
        if (([showInGSCServerList state]) && ([isOnlineServer state])) {
            [self gscServerSignOn];
        }
        
        myTask = [[NSTask alloc] init]; // set up to launch
        toPipe = [NSPipe pipe];
        fromPipe = [NSPipe pipe];
        toTask = [toPipe fileHandleForWriting];
        fromTask = [fromPipe fileHandleForReading];

        [myTask setStandardOutput: fromPipe];
        [myTask setStandardInput: toPipe];
        [myTask setCurrentDirectoryPath: currentFolder];
        [myTask setLaunchPath: completeGamePath];
        [myTask setArguments: arguments];
        // set the notification center for redirecting stdout to textview
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gotData:)
                                                     name:NSFileHandleReadCompletionNotification
                                                   object:fromTask];
        [fromTask readInBackgroundAndNotify];
        // start the launchGame thread
        [NSThread detachNewThreadSelector:@selector(launchGameThread) toTarget:self withObject:nil];
    }
    [pool release];
}

- (void)launchGameThread
// This method launches the game, and does a looped check if the game runs, and polls the server for info.
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    [myTask launch]; // launches the game

    gameIsRunning = [myTask isRunning];
    weHaveToQuit=NO;

    // the polling starts here
    if (gameIsRunning) { // the game is running, now poll until terminate
        // NSLog(@"-------------RUNNING & POLLING FOR EXIT-------------");
        [statusMessage setStringValue: GEN_RUNNING]; // set statusmessage
        [spinner stopAnimation:self]; // stop the progress indicator

        // start polling until game has terminated
        NSDate *pollDate = [NSDate dateWithTimeIntervalSinceNow: RUNPOLLWAITTIME];
        NSDate *messageDate = [NSDate dateWithTimeIntervalSinceNow: ([servMessTime intValue] * 60)];
        NSDate *messageLineDate = [NSDate dateWithTimeIntervalSinceNow: ([servMessTime intValue] * 60)];
        NSDate *heartBeatDate = [NSDate dateWithTimeIntervalSinceNow: HEARTBEATTIME];

        [currentServMess setStringValue: MAN_WAITMESSAGE];
        // settings for the server messages
        NSMutableArray *servMessLines = [[NSMutableArray alloc] init];
        [servMessLines addObjectsFromArray:[[servMessText stringValue] componentsSeparatedByString:@"\n"]]; // message lines
        [servMessLines addObject: SERVMESSGREETING];
        NSMutableString *currentLine = [[NSMutableString alloc] init];
        NSEnumerator *e = [servMessLines objectEnumerator];
        NSNumber *cur;
        unsigned int c=0;
        NSMutableString *lineCommand = [[NSMutableString alloc] init];
        
        while (gameIsRunning) {
            // sleep for a second
            [NSThread sleepUntilDate:[[NSDate date] addTimeInterval:1]];
            gameIsRunning = [myTask isRunning];

            if ((gameIsRunning) && (!weHaveToQuit)) { // while the game still runs
                // poll the server for status
                if ([pollDate timeIntervalSinceDate:[NSDate date]] < 0) { // is it time to poll?
                    [self pollServer]; // poll now!
                    
                    // autokick if necessary
                    if ([enableAutoKick intValue] == 1) {
                        [self autoKickPlayers]; // auto kick players
                    }
                    
                    // do leading player message if necessary
                    if (([leadMessEnabled state]) && ([playerArray count] > 0)) {
                        //NSLog(@"Checking lead player...");
                        // check if not everyone has the same score
                        int lead;
                        int bestScore = [[[playerArray objectAtIndex:0] objectAtIndex:2] intValue];
                        BOOL otherScoresFound = NO;
                        for (lead = 0; lead < [playerArray count]; lead++) {
                            if ([[[playerArray objectAtIndex:lead] objectAtIndex:2] intValue] != bestScore) {
                                otherScoresFound = YES;
                            }
                        }

                        // if other scores are found, find the best and worst player(s)
                        if (otherScoresFound) {
                            //NSLog(@"Other scores found!");
                            // find best player(s)
                            NSMutableString *bestPlayer = [[NSMutableString alloc] init];
                            [bestPlayer setString:[[playerArray objectAtIndex:0] objectAtIndex:3]];
                            int playerCount = 1;
                            for (lead = 1; lead < [playerArray count]; lead++) {
                                if ([[[playerArray objectAtIndex:lead] objectAtIndex:2] intValue] == bestScore) {
                                    [bestPlayer appendString:@" & "]; // append the name
                                    [bestPlayer appendString:[[playerArray objectAtIndex:lead] objectAtIndex:3]];
                                    playerCount++;
                                }
                            }
                            if ((playerCount == 3) || (playerCount == 2)) { // 2 or 3 best
                                //NSLog(@"Messaging...");
                                [self talkToServer:[NSString stringWithFormat:GAM_LEADPLAYER2, bestPlayer, bestScore]];
                            } else {
                                if (playerCount == 1) { // the leader
                                 //NSLog(GAM_LEADPLAYER1, bestPlayer, bestScore);
                                    [self talkToServer:[NSString stringWithFormat:GAM_LEADPLAYER1, bestPlayer, bestScore]];
                                }
                            }

                            // find worst player(s)
                            NSMutableString *worstPlayer = [[NSMutableString alloc] init];
                            [worstPlayer setString:[[playerArray objectAtIndex:[playerArray count]-1] objectAtIndex:3]];
                            int worstScore = [[[playerArray objectAtIndex:[playerArray count]-1] objectAtIndex:2] intValue];
                            playerCount = 1;
                            for (lead = 0; lead < [playerArray count]-1; lead++) {
                                if ([[[playerArray objectAtIndex:lead] objectAtIndex:2] intValue] == worstScore) {
                                    [worstPlayer appendString:@" & "]; // append the name
                                    [worstPlayer appendString:[[playerArray objectAtIndex:lead] objectAtIndex:3]];
                                    playerCount++;
                                }
                            }
                            if ((playerCount == 3) || (playerCount == 2)) { // 2 or 3 worst
                                //NSLog(@"Messaging...");
                                [self talkToServer:[NSString stringWithFormat:GAM_LASTPLAYER2, worstPlayer, worstScore]];
                            } else {
                                if (playerCount == 1) { // the worst!
                                    //NSLog(@"Messaging...");
                                    [self talkToServer:[NSString stringWithFormat:GAM_LASTPLAYER1, worstPlayer, worstScore]];
                                }
                            }
                        } // otherScoresFound=NO, the scores are TIED!
                    }
                    pollDate = [[NSDate date] addTimeInterval: RUNPOLLWAITTIME];
                }

                // do server messages if necessary
                if ([servMessEnabled state]) {
                    if ([messageDate timeIntervalSinceDate:[NSDate date]] < 0) {
                        if ([messageLineDate timeIntervalSinceDate:[NSDate date]] < 0) {
                            if (cur = (NSNumber *)[e nextObject]) { // next line
                                [currentLine setString:[servMessLines objectAtIndex:c++]];
                        //        NSLog(@"line: %@", currentLine);
                                if ([currentLine length] > 0) {
                                    // show it in management window if it's a user line
                                    if (![currentLine isEqualToString:SERVMESSGREETING]) {
                                        [currentServMess setStringValue: currentLine];
                                    }
                                    // SEND THE LINE HERE
                                    [lineCommand setString:@"say "];
                                    [lineCommand appendString: currentLine];

                                    // send the command
                                    [self talkToServer:lineCommand];
                                    messageLineDate = [messageLineDate addTimeInterval: [servMessWait intValue]]; // set a new time
                                }
                            } else { // no more lines
                                // set new message times
                                messageDate = [[NSDate date] addTimeInterval: ([servMessTime intValue] * 60)];
                                messageLineDate = [[NSDate date] addTimeInterval: ([servMessTime intValue] * 60)];
                                // reset the message enumerator
                                c = 0;
                                e = [servMessLines objectEnumerator];
                            }
                        }
                    }
                }
                
                // send a heartbeat to the GSC server if necessary
                if ([heartBeatDate timeIntervalSinceDate:[NSDate date]] < 0) {
                    [self gscServerSignOn];
                    heartBeatDate = [[NSDate date] addTimeInterval: HEARTBEATTIME];
                }
            } else {
                // if we have to quit we will tell the server to quit
                // this is done here to make sure all processes are done before quitting
                if ((weHaveToQuit) && (gameIsRunning)) { 
                    [self talkToServer:@"quit"];
                }
            }
        }
    }

    // the game app has terminated
    // NSLog(@"-------------TERMINATED-------------");
    
    [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_GOINGDOWN1];
    
    // wait a second for dramatic effect
    [NSThread sleepUntilDate:[[NSDate date] addTimeInterval:1]];
    
    [launchButton setEnabled: YES]; // enable the launch button

    // set menu items
    [launchMenuItem setEnabled : YES]; // enable the launch menu item
    [stopMenuItem setEnabled : NO]; // disable the stop menu item
    [fileNewMenuItem setEnabled : YES];
    [fileOpenMenuItem setEnabled : YES];
    [fileRecentMenuItem setEnabled: YES];
    [mapMenuItem setEnabled: NO];
    [talkMenuItem setEnabled: NO];
    [kickMenuItem setEnabled: NO];
    [banMenuItem setEnabled: NO];
    [quitMenuItem setEnabled: YES];
    [prefsMenuItem setEnabled: YES];
    [checkUpdateMenuItem setEnabled: YES];

    // remove the server config file
    NSMutableString *configFilePath = [[NSMutableString alloc] initWithString:[[gameFolder stringValue] stringByAppendingString: CONFIGFILENAME]]; // set the config filename

    NSFileManager * manager = [NSFileManager defaultManager];
    [manager removeFileAtPath:configFilePath handler:nil]; // remove configfile
    
    // here we are going to submit this server (signoff) to the main GSC Server list
    if (([showInGSCServerList state]) && ([isOnlineServer state])) {
        [self gscServerSignOff];
    }

    [statusMessage setStringValue: GEN_NOTRUNNING]; // set statusmessage
    
    // wait a second for dramatic effect
    [NSThread sleepUntilDate:[[NSDate date] addTimeInterval:1]];

    if (banListChanged) {
        [docController getBanlistFromBanlistString]; // save the new banliststring if there was a ban
    }
    
    [mainController updateApplicationBadge:0]; // remove the player count in the dock icon
    [self hideManagementWindow]; // close the management window
    
    // release stuff
    gameIsRunning = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [pool release];
}

- (void) gotData:(NSNotification *)notification
    // notification that receives data from the UNIX pipe and puts it into the TextView and the io buffer.
{
    NSData *data;
    NSString *str;
    
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    // append the text to the end of the textview box
    int len = [[theText textStorage] length];
    if (len > MAXCONSOLESIZE) { // truncate the console when it's too large
        [theText replaceCharactersInRange:NSMakeRange(0, len) withString:str];
    } else {
        [theText replaceCharactersInRange:NSMakeRange(len, 0) withString:str];
    }
    [theText scrollRangeToVisible: NSMakeRange([[theText textStorage] length], 0)];
    
    [fromTask readInBackgroundAndNotify];
    [pool release];
}

- (IBAction)manKickPlayer:(id)sender
// This method kicks the selected player from the server
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    int n = [playerTable numberOfSelectedRows]; // number of selected rows

    if (n == 1) { // one or more players were selected
        NSEnumerator *e = [playerTable selectedRowEnumerator];
        NSNumber *cur;

        while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
            NSMutableArray *aPlayer = [playerArray objectAtIndex:[cur intValue]];
            NSMutableString *kickCommand = [[NSMutableString alloc] initWithString:@"clientkick "];
            [kickCommand appendString:[NSString stringWithFormat:@"%d", [[aPlayer objectAtIndex:0] intValue]]];

            //NSLog(@"kick: %@", kickCommand);
            [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
            [manServerStatus setStringValue: [NSString stringWithFormat: MAN_PLAYERKICKED, [aPlayer objectAtIndex:3]]]; // set statusmessage
            [manServerStatus setTextColor: [NSColor blueColor]]; // set color

            // send the kick command
            [self talkToServer:[NSString stringWithFormat:GAM_USERKICKED, [aPlayer objectAtIndex:3]]]; // tell the players
            [self talkToServer:kickCommand];

            // do not remove players from the list because auto-kick may be using the list right now! instead, alter the name
            [aPlayer replaceObjectAtIndex:3 withObject:MAN_KICKEDPL];
            // wait a second for dramatic effect
            [NSThread sleepUntilDate:[[NSDate date] addTimeInterval:0.5]];
            [playerTable reloadData];
                
            [manSpinner stopAnimation:self]; // stop the management progress indicator (spinner)
        }
    }
    
    [pool release];
}

- (IBAction)manBanPlayer:(id)sender
// this method bans the selected player(s) from the server.
{   
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    int n = [playerTable numberOfSelectedRows]; // number of selected rows
    
    if (n == 1) { // one or more players were selected
        NSEnumerator *e = [playerTable selectedRowEnumerator];
        NSNumber *cur;
        
        while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
            NSArray *aPlayer = [playerArray objectAtIndex:[cur intValue]];
            NSString *currentIP = [[NSString alloc] initWithString:[[playerArray objectAtIndex:[cur intValue]] objectAtIndex:4]];
            NSMutableString *currentBanList = [[NSMutableString alloc] initWithString:[bannedListString stringValue]];
            
            if (![currentIP isEqualToString:@"IP Error"]) {
                NSBeep();
                int button = NSRunAlertPanel([NSString stringWithFormat:ALE_BANTHISPLAYER1, currentIP], [NSString stringWithFormat:ALE_BANTHISPLAYER2, [aPlayer objectAtIndex:3]], ALE_OKBUTTON, ALE_CANCELBUTTON, nil);
                if (button == NSOKButton) { // yes, save it
                    banListChanged = YES;
                    [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
                    [self talkToServer:[NSString stringWithFormat:GAM_USERBANNED, [aPlayer objectAtIndex:3]]]; // tell the players
                    [manServerStatus setStringValue: [NSString stringWithFormat: MAN_PLAYERBANNED, [aPlayer objectAtIndex:3]]]; // set statusmessage
                    [manServerStatus setTextColor: [NSColor blueColor]]; // set color
        
                    //NSLog(@"Banlist before: %@", [bannedListString stringValue]);
                    if ([currentBanList length] > 0) {
                        [currentBanList appendString:@" "]; // only append a space if the string is not empty
                    }
                    [currentBanList appendString:currentIP];
                    [bannedListString setStringValue:currentBanList];
                    //NSLog(@"Banlist after: %@", [bannedListString stringValue]);
                
                    [manSpinner stopAnimation:self]; // stop the management progress indicator (spinner)
                }
            } else {
                // Ip error, or it is a bot
                //NSLog (@"IP error!");
            }
        }
    }
    
    [pool release];
}

- (void)autoKickPlayers
    // this method auto kicks all players that are in the banlist (by IP)
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSEnumerator *e = [playerArray objectEnumerator];
    NSNumber *cur;
    unsigned int c=0;
    
    // put the banned string into an array
    NSArray *bannedIPs = [[bannedListString stringValue] componentsSeparatedByString:@" "];
    
    while (cur = (NSNumber *)[e nextObject]) { // traverse the playerlist
        NSString *currentIP = [[NSString alloc] initWithString:[[playerArray objectAtIndex:c] objectAtIndex:4]];
        //NSLog(@"Player IP: %@", currentIP);
        
        NSEnumerator *f = [bannedIPs objectEnumerator];
        NSNumber *this;
        unsigned int d=0;
        
        while (this= (NSNumber *)[f nextObject]) { // traverse the banned IP list
            // NSLog(@"current IP: %@, list IP: %@", currentIP, [bannedIPs objectAtIndex:d]);
            if ([[bannedIPs objectAtIndex:d] isEqualToString:currentIP]) { // is the IP banned?
                NSMutableArray *aPlayer = [playerArray objectAtIndex:c];
                NSMutableString *kickCommand = [[NSMutableString alloc] initWithString:@"clientkick "];
                [kickCommand appendString:[NSString stringWithFormat:@"%d", [[aPlayer objectAtIndex:0] intValue]]];
            
                //NSLog(@"Autokick: %@", kickCommand);
            
                // send the kick command
                [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
                [manServerStatus setStringValue: [NSString stringWithFormat: MAN_AUTOKICKED, [aPlayer objectAtIndex:3]]]; // set statusmessage
                [manServerStatus setTextColor: [NSColor blueColor]]; // set color
                [self talkToServer:[NSString stringWithFormat:GAM_AUTOKICKED, [aPlayer objectAtIndex:3], currentIP]]; // tell the players
                [self talkToServer:kickCommand];
            
                // do not remove players from the list because auto-kick may be using the list right now! instead, alter the name
                [aPlayer replaceObjectAtIndex:3 withObject:MAN_AUTOKICKEDPL];
                [playerTable reloadData];
            }
            d++;
        }
        c++;
    }
    
    [manSpinner stopAnimation:self]; // stop the management progress indicator (spinner)
    [pool release];
}

- (IBAction)rconCommand:(id)sender
// This method sends an rconcommand, typed into the user field, to the server
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableString *rconCommand = [[NSMutableString alloc] init];
    NSString *tempCommand = [[NSString alloc] initWithString:[rconCommandText stringValue]];

    if ([tempCommand hasPrefix:@"/"]) { // it is a real command
        [rconCommand setString:tempCommand];
        [rconCommand deleteCharactersInRange:NSMakeRange(0, 1)];
    } else { // it is a chat line
        [rconCommand setString:@"say "];
        [rconCommand appendString:tempCommand];
    }

 //   NSLog(@"rconCommand: %@", rconCommand);
    [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
    [manServerStatus setStringValue: MAN_MESSAGESENT]; // set statusmessage
    [manServerStatus setTextColor: [NSColor blueColor]]; // set color
    
    [self talkToServer: rconCommand];
    
    [manSpinner stopAnimation:self]; // stop the management progress indicator (spinner)
    
    [pool release];
}

-(void)pollServer
// This method polls the server through a UDP connection and extracts the necessary info
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];

    // request statusinfo from server
    [self talkToServer:@"status"];
    NSMutableString *serverResponse = [[NSMutableString alloc] initWithString:[theText string]];

 //   NSLog (@"====================================== rx:\n%@", serverResponse);
 //   NSLog (@"reading backwards...");

    // put the received data in an array separated by newline
    NSMutableArray *rxLines = [[NSMutableArray alloc] init];
    [rxLines addObjectsFromArray:[serverResponse componentsSeparatedByString:@"\n"]];

    unsigned int start = [rxLines count];
    unsigned int finish = 0;
    NSMutableString *currentLine = [[NSMutableString alloc] init];
    BOOL foundStart = NO;
    BOOL foundFinish = NO;

    // traverse backwards and find "map: " and other useful info
    while ((start > 0) && (!foundStart)) {
        if ([[rxLines objectAtIndex:--start] hasPrefix:@"map: "]) {
            foundStart = YES;
          //  NSLog(@"START: %d", start);
            [manSpinner stopAnimation:self]; // stop the management progress indicator (spinner)
            [manServerStatus setStringValue: GEN_RUNNING]; // set statusmessage
            [manServerStatus setTextColor: [NSColor blackColor]]; // set color
        }
        // Check if server is not running
        if ([[rxLines objectAtIndex:start] isEqualToString:@"Server is not running."]) {
           // NSLog(@"SERVER IS DOWN!");
            [manServerStatus setStringValue: GEN_NOTRUNNING]; // set statusmessage
            [manServerStatus setTextColor: [NSColor redColor]]; // set color
        }
    }

   // NSLog (@"reading forwards...");
    // if found, traverse forward and find a blank line
    if (foundStart) {
        finish = start;
        while ((finish < [rxLines count]) && (!foundFinish)) {
            finish++;
            [currentLine setString:[rxLines objectAtIndex:finish]]; // pick a line
            //NSLog(@"=== Length %d: %@", [currentLine length], currentLine);
            if ([currentLine length] == 0) { // blank line?
                foundFinish = YES;
            //    NSLog(@"FINISH: %d", finish);
            } else {
                if ([currentLine length] <= 30) { // non player line!
                    finish = [rxLines count]; // quit the loop
                    foundStart = NO; // something is wrong, kill it
                }
            }
        }
    }

    // if a full list was found, display it
    if ((foundStart) && (foundFinish)) {
     //   NSLog(@"It's OK!");
        unsigned int c;
        int botCounter = 0;
        int lineLen = 0; // for correting shorter lines

        [playerArray removeAllObjects]; // clear the player list
        // traverse the output lines and analyze
        for (c = start; c < finish; c++) {
            [currentLine setString:[rxLines objectAtIndex:c]]; // set the current line
            //NSLog(@"=== Line\n%@\n", currentLine);
            if (c == start) { // get mapname
                [manCurrentMap setStringValue:[[currentLine componentsSeparatedByString:@": "] objectAtIndex:1]];
            } else {
                if (c >= (start+3)) { // get player name
                    //NSLog(@"=== Length %d: %@", [currentLine length], currentLine);
                    NSMutableArray *aPlayer = [[NSMutableArray alloc] init];
                    [aPlayer addObject:[currentLine substringWithRange:NSMakeRange(0, 3)]]; // num
                    // look for a bot, in this fucked up construction because the MakeRange
                    // cannot be done when the line is smaller due to player name colors
                    if ([currentLine length] == STATUSLINELEN) { // look for a bot
                        if ([[currentLine substringWithRange:NSMakeRange(57, 3)] isEqualToString:@"bot"]) { // it is a bot
                            [aPlayer addObject:@"bot"]; // ping for the bot
                        } else {
                            [aPlayer addObject:[currentLine substringWithRange:NSMakeRange(10, 4)]]; // normal player ping
                        }
                    } else {
                        [aPlayer addObject:[currentLine substringWithRange:NSMakeRange(10, 4)]]; // player ping
                    }
                    [aPlayer addObject:[currentLine substringWithRange:NSMakeRange(4, 5)]]; // score
                    
                    lineLen = (STATUSLINELEN-[currentLine length]-1); // this corrects names longer than 15 chars
                    [aPlayer addObject:[currentLine substringWithRange:NSMakeRange(15, (15-lineLen))]]; // player name
                    
                    // The Player IP is found by reading the line backwards until a colon was found.
                    // Left of the colon is the IP, right of the colon is the Port number.
                    NSMutableString *playerIP = [[NSMutableString alloc] initWithString:@"0.0.0.0"];
                    int c = [currentLine length];
                    int colonpos = 0;
                    BOOL found = NO;
                    while ((!found) && (c-- > 15)) {
                        if ([currentLine characterAtIndex: c] == ':') {
                            found = YES;
                            colonpos = c;
                            //NSLog(@"Found \':\' in player name at: %d", c);
                        }
                    }
                    
                    if (found) { // player IP can be found
                        // read backwards until a space and then we're at the beginning of the IP string
                        c = colonpos;
                        found = NO;
                        while ((!found) && (c-- > 15)) {
                            if ([currentLine characterAtIndex: c] == ' ') {
                                found = YES;
                                //NSLog(@"Found \' \' in player name at: %d", c);
                                [playerIP setString:[currentLine substringWithRange:NSMakeRange(c+1, colonpos-c-1)]];
                                //NSLog(@"Player IP: %@", playerIP);
                            }
                        }
                    } else {
                        [playerIP setString:@"IP Error"];
                    }
                    
                    [aPlayer addObject:playerIP]; // add player IP.
                    
                    // insert player at correct position, sorted by score
                    int s;
                    BOOL added = NO;
                    for (s = 0; s < [playerArray count]; s++) {
                        if ([[[playerArray objectAtIndex:s] objectAtIndex:2] intValue] <= [[aPlayer objectAtIndex:2] intValue]) {
                            [playerArray insertObject:aPlayer atIndex:(s)];
                          //  NSLog(@"loop add: %@", [aPlayer objectAtIndex:3]);
                            added = YES;
                            break; // kill the loop
                        }
                    }
                    if (!added) { // if it has not been added yet by the sortloop
                        [playerArray addObject:aPlayer]; // add player to the list
                       // NSLog(@"appended: %@", [aPlayer objectAtIndex:3]);
                    }
                }
            }
        }

        /************************************************************************
            random player generator for testing purposes BEGIN
        *************************************************************************
        int i;
        int rndnum=rand() / (double)RAND_MAX * MAXAUTOGENPLYR;
        
        for (i=0; i<rndnum; i++) {
            NSMutableArray *aPlayer = [[NSMutableArray alloc] init];
            [aPlayer addObject:[NSString stringWithFormat:@"%d", i+65]];
            [aPlayer addObject:@"---"];
            int rnd=rand() / (double)RAND_MAX * 25;
            [aPlayer addObject:[NSString stringWithFormat:@"%d", (int) rnd]];
            [aPlayer addObject:[NSString stringWithFormat:@"Autogen %d", i+100]];
            [aPlayer addObject:@"10.10.10.10"];
            [playerArray addObject:aPlayer];
        }
        ************************************************************************
         random player generator for testing purposes END
        *************************************************************************/
        
        // set the number of players and display the player table
        [noOfPlayers setStringValue:[NSString stringWithFormat: MAN_CONNECTED, [playerArray count] - botCounter, botCounter]];
        [mainController updateApplicationBadge:[playerArray count]];
        [playerTable reloadData];
    } else {
     //   NSLog(@"No player list completed...");
    }

    [pool release];
}

- (void)talkToServer:(NSString *)command
// this method sends a command to the server
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];

    // set the string for the rcon command
    NSMutableString *rconString = [[NSMutableString alloc] initWithString:command];
    [rconString appendString:@"\n"];

    //NSLog(@"string: %@", rconString);
    NSData *sendData = [rconString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    [toTask writeData:sendData];

    // wait a second to prevent too many talks
    [NSThread sleepUntilDate:[[NSDate date] addTimeInterval:0.25]];
    [pool release];
}

- (void)showManagementWindow
// this method shows the management window and closes the mainwindow
{
    [managementWindow orderFront:self];
    [mainWindow orderOut:self];
}

- (void)hideManagementWindow
// this method hides the management window and shows the mainwindow
{
    [mainWindow orderFront:self];
    [noOfPlayers setStringValue: MAN_WAITFORSTART];
    [manCurrentMap setStringValue: MAN_WAITFORSTART];
    [managementWindow orderOut:self];
}

- (IBAction)quitGame:(id)sender
// this method kills the server
{
    if ([noOfPlayers intValue] != 0) {
        NSBeep();
        int button = NSRunAlertPanel(ALE_PLAYERSCNNCT1, ALE_PLAYERSCNNCT2, ALE_CANCELBUTTON, ALE_OKBUTTON, nil);

        if (button == NSCancelButton) { // they chose OK button
            [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
            [manQuitButton setEnabled:NO]; // disable quit button
            [manServerStatus setStringValue: MAN_GOINGDOWN2]; // set statusmessage
            [manServerStatus setTextColor: [NSColor blueColor]]; // set color
            [self talkToServer:GAM_GOINGDOWN]; // tell the players
            weHaveToQuit = YES;
        }
    } else { // there are no players, just quit
        [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
        [manQuitButton setEnabled:NO]; // disable quit button
        [manServerStatus setStringValue: MAN_GOINGDOWN2]; // set statusmessage
        [manServerStatus setTextColor: [NSColor blueColor]]; // set color
        [self talkToServer:GAM_GOINGDOWN]; // tell the players
        weHaveToQuit = YES;
    }
}

- (IBAction)changeMap:(id)sender
// changes current map
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableString *mapCommand = [[NSMutableString alloc] initWithString:@"map "];
    [mapCommand appendString:[mapSelector titleOfSelectedItem]];
    [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
    [manServerStatus setStringValue: MAN_MAPCHANGING]; // set statusmessage
    [manServerStatus setTextColor: [NSColor blueColor]]; // set color
    [self talkToServer:GAM_MAPCHANGED]; // tell the players
    [self talkToServer:mapCommand]; // do it
    
    [manSpinner stopAnimation:self]; // stop the management progress indicator (spinner)
    
    [pool release];
}

- (IBAction)changeMapButtonControl:(id)sender
// disables and enables "change map" button
{
    if ([mapSelector indexOfSelectedItem] >= 1) { // skip the first item
        [mapSelectorButton setEnabled: YES];
        [mapMenuItem setEnabled: YES];
    } else {
        [mapSelectorButton setEnabled: NO];
        [mapMenuItem setEnabled: NO];
    }
}

- (IBAction)changeBotsAmount:(id)sender
// this method changes the amount of bots on the server
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    [manSpinner startAnimation:self]; // start the management progress indicator (spinner)
    [manServerStatus setStringValue: MAN_BOTSCHANGING]; // set statusmessage
    [manServerStatus setTextColor: [NSColor blueColor]]; // set color
    
    // check bots values
    [botsLabel setStringValue:[manSetBotsLabel stringValue]];
    [self checkBotsValue];
    
    NSMutableString *mapCommand = [[NSMutableString alloc] initWithString:@"set bot_minplayers "];
    [mapCommand appendString:[manSetBotsLabel stringValue]];
    
    [self talkToServer:[NSString stringWithFormat:GAM_BOTSCHANGED, [manSetBotsLabel stringValue]]]; // tell the players
    [self talkToServer:mapCommand]; // do it
    
    [manSpinner stopAnimation:self]; // stop the management progress indicator (spinner)
    
    [pool release];
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
// just returns the number of items we have for table
{
    return [playerArray count];
}

// connect the tableview to the correct array
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    NSString *column = [tableColumn identifier];
    if ([playerArray count] > 0) {
        return [[playerArray objectAtIndex:row] objectAtIndex:[column intValue]];
    } else {
        return 0;
    }
}

- (IBAction)checkBotsValueAction:(id)sender
{
    [self checkBotsValue];
}

- (void)checkBotsValue
// this method checks if more bots than players are selected
{
    if ([[botsLabel stringValue] length] == 0) { [botsLabel setStringValue:@"0"]; }
    if (([botsLabel intValue] >= [setMaxPlayers intValue]) && ([setMaxPlayers intValue] != 0)) {
        NSBeep();
        int button = NSRunAlertPanel(ALE_BOTSPLAYERS1, [NSString stringWithFormat:ALE_BOTSPLAYERS2, [botsLabel intValue], [setMaxPlayers intValue]], ALE_CORRECT, ALE_NEVERMIND, nil);
        if (button == NSOKButton) {
            [botsLabel setStringValue:@"0"];
            [manSetBotsLabel setStringValue:[botsLabel stringValue]];
        }
    }
}

- (BOOL)gameProcessRuns
// checks the process list to check if game is running
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableString * gameAppName = [[NSMutableString alloc] initWithString:GAMEAPPNAME]; // game app file
    [gameAppName setString:[gameAppName substringFromIndex:1]];; // remove first / char
    
    // fill the array dictionary with list of running applications
    NSMutableArray *resultsArray=[NSMutableArray array];
    OSErr resultCode=noErr;
    ProcessSerialNumber serialNumber;
    ProcessInfoRec procInfo;
    FSSpec appFSSpec;
    Str255 procName;
    serialNumber.highLongOfPSN = kNoProcess;
    serialNumber.lowLongOfPSN = kNoProcess;
    procInfo.processInfoLength =sizeof(ProcessInfoRec);
    procInfo.processName=procName;
    procInfo.processAppSpec = &appFSSpec;
    procInfo.processAppSpec = &appFSSpec;
    while (procNotFound != (resultCode = GetNextProcess(&serialNumber))) {
        if (noErr ==(resultCode = GetProcessInformation(&serialNumber,&procInfo))) {
            if (procName[1] == nil) procName[1] = '0';
            [resultsArray addObject:(NSString*)CFStringCreateWithPascalString(NULL,procInfo.processName,kCFStringEncodingMacRoman)];
        }
    }
    
    //NSLog(@"Game: %@", gameAppName);
    
    NSEnumerator *appEnumerator = [resultsArray objectEnumerator];
    NSNumber *cur;
    int counter = 0;
    BOOL gameProcessFound = NO;
    
    // traverse array to find our gameAppName
    while ((cur = [appEnumerator nextObject]) && !gameProcessFound) {
        //NSLog(@"App: %@", [resultsArray objectAtIndex:counter]);
        if ([[resultsArray objectAtIndex:counter] isEqualToString:gameAppName]) {
            gameProcessFound = YES; // the game app is running
        }
        counter++;
    }
    
    [pool release];
    return gameProcessFound;
}

- (void)gscServerSignOn
// signs our game on to the GSC main serverlist
{
    [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN1];
    
    NSMutableString *signOnString = [[NSMutableString alloc] init];
    [signOnString setString:[NSString stringWithFormat:GSC_SERV_SIGNON, [preferences objectForKey:@"serverID"], [serverName stringValue], [adminName stringValue], VERSIONDICTKEY, [serverLocation stringValue], [setNetPort intValue]]];
    NSString * escapedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)signOnString, NULL, NULL, kCFStringEncodingISOLatin1);
    //NSLog(@"Sending heartbeat to the main GSC server...\n%@", escapedString);
    
    // connect to the web and get the XML reply
    NSDictionary *mainServerReply = [NSDictionary dictionaryWithContentsOfURL: [NSURL URLWithString:escapedString]];
    NSString *success = [mainServerReply valueForKey:@"success"];
    NSString *srvid = [mainServerReply valueForKey:@"id"];
    
    if (success == nil) { // no xml file could be found
        //NSLog(@"No connection with the main GSC server for signing on!");
        [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN4];
    } else { // we have a reply
        // NSLog(@"Reply: %@", mainServerReply);
        if ([success isEqualToString:@"yes"]) { // the submit was successful
            [preferences setObject:srvid forKey:@"serverID"]; // put it in user prefs
            //NSLog(@"GSC main server submit was succesful, server ID = %@.", srvid);
            [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN2];
        } else { // we have a non-succesful submit
            [preferences setObject:@"" forKey:@"serverID"]; // empty the serverID in user prefs
            //NSLog(@"GSC main server submit has failed!");
            [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN3];
        }
    }
}

- (void)gscServerSignOff
// signs our game off in the GSC main serverlist
{
    NSMutableString *signOnString = [[NSMutableString alloc] init];
    [signOnString setString:[NSString stringWithFormat:GSC_SERV_SIGNOFF, [preferences objectForKey:@"serverID"], [serverName stringValue], [adminName stringValue], VERSIONDICTKEY, [serverLocation stringValue], [setNetPort intValue]]];
    NSString * escapedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)signOnString, NULL, NULL, kCFStringEncodingISOLatin1);
    //NSLog(@"Signing off at the main GSC server...\n%@", escapedString);
    
    // connect to the web and get the XML reply
    [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN1];
    
    NSDictionary *mainServerReply = [NSDictionary dictionaryWithContentsOfURL: [NSURL URLWithString:escapedString]];
    NSString *success = [mainServerReply valueForKey:@"success"];
    // NSString *srvid = [mainServerReply valueForKey:@"id"];
    
    if (success == nil) { // no xml file could be found
        // NSLog(@"No connection with the main GSC server for signing off!");
        [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN4];
    } else { // we have a reply
        // NSLog(@"Reply: %@", mainServerReply);
        if ([success isEqualToString:@"yes"]) { // the submit was successful
            // NSLog(@"GSC main server submit was succesful, server ID = %@.", srvid);
            [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN2];
        } else { // we have a non-succesful submit
            [preferences setObject:@"" forKey:@"serverID"]; // empty the serverID in user prefs
            // NSLog(@"GSC main server submit has failed!");
            [theText replaceCharactersInRange:NSMakeRange([[theText textStorage] length], 0) withString: MAN_CONNECTMAIN3];
        }
    }
}

@end

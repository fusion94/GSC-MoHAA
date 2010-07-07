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

#import "DocController.h"
#import "MainController.h"
#import "LaunchController.h"
#import "define.h"
#import "messages.h"

@implementation DocController

- (IBAction)addMap:(id)sender
// this method adds a map to the rotation
{
    int n = [availableMaps numberOfSelectedRows]; // number of selected rows

    if (n>0) { // something was selected
        NSEnumerator *e = [availableMaps selectedRowEnumerator];
        NSNumber *cur;

        serverEdited = YES;
        
        while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
            if ([selectedMapArray count] < MAXMAPLISTSIZE) {
                [selectedMapArray addObject: [availableMapArray objectAtIndex:[cur intValue]]]; // add the mapname to the array
            } else {
                NSBeep();
            }
        }
    }
    [self refreshSelectedTableTitle];
}

- (IBAction)removeMap:(id)sender
// this method removes a map from the rotation
{
    int n = [selectedMaps numberOfSelectedRows]; // number of selected rows

    if (n>0) { // something was selected
        NSEnumerator *e = [selectedMaps selectedRowEnumerator];
        NSNumber *cur;
        int counter=0;

        serverEdited = YES;

        while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
            if ([selectedMapArray count] >1) {
                [selectedMapArray removeObjectAtIndex: ([cur intValue]-counter)]; // remove the map
                 counter++;
            } else {
                NSBeep(); // you have to have 1 map left
            }
        }
    }
    [self refreshSelectedTableTitle];
}

- (IBAction)moveMapDown:(id)sender
// this method moves a map down in rotation
{
    int n = [selectedMaps numberOfSelectedRows]; // number of selected rows

    if (n>0) { // something was selected
        NSEnumerator *e = [selectedMaps selectedRowEnumerator];
        NSNumber *cur;
        NSString *temp;
        int insertSpace;

        cur = (NSNumber *)[e nextObject]; // pick the first selected row
        int last = [cur intValue] + n;

        if (([cur intValue] + n) != [selectedMapArray count]) { // if we're not already at the bottom
            insertSpace = ([cur intValue]);
            temp = [selectedMapArray objectAtIndex: ([cur intValue] + n)];
            [selectedMapArray removeObjectAtIndex: ([cur intValue] + n)]; // remove the map below the selection
            [selectedMapArray insertObject:temp atIndex:insertSpace]; // insert the temp above the selection

            // move the selection down as well
            [selectedMaps selectRow:([cur intValue] + n) byExtendingSelection:YES];
            [selectedMaps deselectRow:[cur intValue]];

            serverEdited = YES;
        }
        
        // scroll the view down to the selection
        if (last < [selectedMapArray count] ) {
            [selectedMaps scrollRowToVisible:last];
        }
    }

    [self refreshSelectedTableTitle];
}

- (IBAction)moveMapUp:(id)sender
// this method moves a map up in the rotation
{
    int n = [selectedMaps numberOfSelectedRows]; // number of selected rows

    if (n>0) { // something was selected
        NSEnumerator *e = [selectedMaps selectedRowEnumerator];
        NSNumber *cur;
        NSString *temp;
        int insertSpace;

        cur = (NSNumber *)[e nextObject]; // pick the first selected row
        int first = [cur intValue];

        if ([cur intValue] != 0) { // if we're not already at the top
            insertSpace = ([cur intValue] + n - 1);
            temp = [selectedMapArray objectAtIndex: ([cur intValue]-1)];
            [selectedMapArray removeObjectAtIndex: ([cur intValue]-1)]; // remove the map above the selection
            [selectedMapArray insertObject:temp atIndex:insertSpace]; // insert the temp below the selection

            // move the selection up as well
            [selectedMaps selectRow:([cur intValue] -1) byExtendingSelection:YES];
            [selectedMaps deselectRow:insertSpace];

            serverEdited = YES;
        }
        
        // scroll the view up to the selection
        if (first >= 1) {
            first--;
        }
        [selectedMaps scrollRowToVisible:first];
    }

    [self refreshSelectedTableTitle];
}

- (IBAction)refreshMaps:(id)sender
// this method refreshes the maplist
{
    [self getMapsFromDisk];
}

- (IBAction)selectGameType:(id)sender
// this method gets maps from disk and sets default rotation
{
    [self getMapsFromDisk]; // read the mapfiles
    [self setDefaultRotation]; // set default maps
    serverEdited = YES;
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView
// just returns the number of items we have for both tables
{
    if (tableView == bannedList) {
        return [banListArray count];
    }
    
    if (tableView == availableMaps) {
        return [availableMapArray count];
    }

    if (tableView == selectedMaps) {
        return [selectedMapArray count];
    } else {
        return 0;
    }
}

// connect the tableview to the correct array for both tables
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if (tableView == bannedList) {
        return [banListArray objectAtIndex:row];
    }
    
    if (tableView == availableMaps) {
        return [availableMapArray objectAtIndex:row];
    }

    if (tableView == selectedMaps) {
        return [selectedMapArray objectAtIndex:row];
    } else {
        return 0;
    }
}

- (IBAction)defaultMaps:(id)sender
// this method sets map rotation to defaults
{
    [self setDefaultRotation];
}

- (void)refreshSelectedTableTitle
// modify the column title for selected maps and put the maps in a string
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSTableColumn *column = [selectedMaps tableColumnWithIdentifier:@"mapName"];
    NSString *title = [NSString stringWithFormat: MAP_INROTATION, [selectedMapArray count]];
    [[column headerCell] setStringValue: title];
    [selectedMaps reloadData];

    // set maplist buttons
    [removeButton setEnabled : ([selectedMapArray count] > 1)];
    [addButton setEnabled : ([selectedMapArray count] < MAXMAPLISTSIZE)];

    // put the maprotation in the maprotationstring
    NSMutableString *rotationString = [[NSMutableString alloc] init];
    NSEnumerator *e = [selectedMapArray objectEnumerator];
    NSNumber *cur;
    int counter=0;

    while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
        [rotationString appendString:[selectedMapArray objectAtIndex:counter++]]; // add the mapname to the string
        [rotationString appendString:@" "];
    }
    
    [mapRotation setStringValue:[rotationString substringToIndex:[rotationString length]-1]];; // set the string
    
    [pool release];
}

- (void)refreshAvailableTableTitle
// modify the column title for available maps and put the maps in a string
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSTableColumn *column = [availableMaps tableColumnWithIdentifier:@"mapName"];
    NSString *title = [NSString stringWithFormat: MAP_AVAILABLE, [availableMapArray count]];
    [[column headerCell] setStringValue: title];
    [availableMaps reloadData];
    
    if ([availableMapArray count] > 0) { // do this if there are maps in the list
        // put the maprotation in the maprotationstring
        NSMutableString *fullMapList = [[NSMutableString alloc] init];
        NSEnumerator *e = [availableMapArray objectEnumerator];
        NSNumber *cur;
        int counter=0;

        while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
            [fullMapList appendString:[availableMapArray objectAtIndex:counter++]]; // add the mapname to the string
            [fullMapList appendString:@" "];
        }

        [availableMapList setStringValue:[fullMapList substringToIndex:[fullMapList length]-1]]; // remove last space
    }
    
    [pool release];
}

- (IBAction)setNetworkDefaults:(id)sender
{
    [self netWorkDefaults];
}

- (IBAction)setServerDefaults:(id)sender
{
    [self serverDefaults];
}

- (IBAction)setGameDefaults:(id)sender
{
    [self gameDefaults];
}

- (void)setDefaultRotation
{
    [selectedMapArray removeAllObjects]; // clear the maplist
    [self defaultMapArray: selectedMapArray]; // set default maps

    [self refreshSelectedTableTitle];
    serverEdited = YES;
}

- (IBAction)addIP:(id)sender
// this method adds the entered IP to the banlist
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    NSMutableString *banIPString = [[NSMutableString alloc] init];
    
    //check if IP address numbers are valid and put them in a string. The IP is first put in a string
    //and then separated again for this reason: when an illegal value is entered, eg. 350 and the user
    //does not tab along to the next field in immediately clicks the Add button, the intValue returns
    //zero (0) but the string formatter uses the entered number anyway. This means the numbers must be
    //put in a string first, and then analysed for illegal values.
    [banIPString setString:[NSString stringWithFormat:@"%d.%d.%d.%d", [ipAddress1 intValue], [ipAddress2 intValue], [ipAddress3 intValue], [ipAddress4 intValue]]];
    
    NSArray * ipComponents = [banIPString componentsSeparatedByString:@"."];
    
    if (([[ipComponents objectAtIndex:0] intValue] < 0) || ([[ipComponents objectAtIndex:0] intValue]> 255) ||
        ([[ipComponents objectAtIndex:1] intValue] < 0) || ([[ipComponents objectAtIndex:1] intValue]> 255) ||
        ([[ipComponents objectAtIndex:2] intValue] < 0) || ([[ipComponents objectAtIndex:2] intValue]> 255) ||
        ([[ipComponents objectAtIndex:3] intValue] < 0) || ([[ipComponents objectAtIndex:3] intValue]> 255)) {
        [banIPString setString:@"0.0.0.0"];
    } 
    
    //NSLog(@"Banned: %@", banIPString);
    
    if ([banListArray count] < MAXBANLISTSIZE) { // is there still room?
        if ([banIPString isEqualToString:@"127.0.0.1"] ||
            [banIPString isEqualToString:@"0.0.0.0"] ||
            [banIPString isEqualToString:@"255.255.255.255"] ) {
            NSBeep();
            int button = NSRunAlertPanel(ALE_CANNOTADDIP1, ALE_CANNOTADDIP2, ALE_OKBUTTON, ALE_ONLINEHELP, nil);
            if (button == NSCancelButton) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_ADDIP_URL]];
            }
        } else { // we are going to add the IP
            // check if it already exists
            NSEnumerator *e = [banListArray objectEnumerator];
            NSNumber *cur;
            int counter=0;
            BOOL found=NO;
            
            while ((cur = (NSNumber *)[e nextObject]) && (!found)) { // traverse the list until found or end
                if ([[banListArray objectAtIndex:counter++] isEqualToString:banIPString]) { // found it
                    found = YES;
                }
            }
            
            if (!found) { // if not found add it to the list
                [banListArray addObject: banIPString]; // add the IP to the array
                serverEdited = YES;
                [self setBanListString];
            
                // display list
                [bannedList reloadData];
                [bannedList selectRow:([banListArray count]-1) byExtendingSelection:NO];
                [bannedList scrollRowToVisible:[banListArray count]-1];
                // set buttons
                [addIPButton setEnabled:([banListArray count] < MAXBANLISTSIZE)];
                [removeIPButton setEnabled:([banListArray count] > 0)];
            } else { // IP was already found in current list
                NSBeep();
                int button = NSRunAlertPanel(ALE_CANNOTADDIP3, ALE_CANNOTADDIP2, ALE_OKBUTTON, ALE_ONLINEHELP, nil);
                if (button == NSCancelButton) {
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_ADDIP_URL]];
                }
            }
        }
    } else { // banlist is full
        NSBeep();
    }

    [pool release];
}

- (IBAction)removeIP:(id)sender
// this method removes the entered IP from the banlist
{
    int n = [bannedList numberOfSelectedRows]; // number of selected rows
    
    if (n>0) { // something was selected
        NSEnumerator *e = [bannedList selectedRowEnumerator];
        NSNumber *cur;
        int counter=0;
        
        while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
            if ([banListArray count] >0) {
                [banListArray removeObjectAtIndex: ([cur intValue]-counter)]; // remove the map
                counter++;
            } else {
                NSBeep(); // cannot remove
            }
        }
        
        serverEdited = YES;
        [self setBanListString];
        
        // display list
        [bannedList reloadData];
        [bannedList selectRow:([banListArray count]-1) byExtendingSelection:NO];
        [bannedList scrollRowToVisible:[banListArray count]-1];
    }
    
    // set buttons
    [removeIPButton setEnabled:([banListArray count] > 0)];
}

- (void)setBanListString
// this method puts the BanList array in a string
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    if ([banListArray count] > 0) {
        NSMutableString *tempString = [[NSMutableString alloc] init];
        NSEnumerator *e = [banListArray objectEnumerator];
        NSNumber *cur;
        int counter=0;
    
        while (cur = (NSNumber *)[e nextObject]) { // traverse the selection
            [tempString appendString:[banListArray objectAtIndex:counter++]]; // add the IP address to the string
            [tempString appendString:@" "];
        }
    
        [bannedListString setStringValue:[tempString substringToIndex:[tempString length]-1]];; // set the string
    } else {
        [bannedListString setStringValue:@""]; // set the string (empty)
    }
    
    [pool release];
}

- (void)defaultMapArray: (NSMutableArray *)aMapArray
// set the default map lists for available maplist AND maprotationlist
{
    // 1=FFA 2=TeamMatch 3=RoundBased 4=Objective
    switch ([[gameType selectedItem] tag]) {
        case 1:
        case 2:
        case 3:
            [aMapArray addObject:@"dm/mohdm1"];
            [aMapArray addObject:@"dm/mohdm2"];
            [aMapArray addObject:@"dm/mohdm3"];
            [aMapArray addObject:@"dm/mohdm4"];
            [aMapArray addObject:@"dm/mohdm5"];
            [aMapArray addObject:@"dm/mohdm6"];
            [aMapArray addObject:@"dm/mohdm7"];
                break;
        case 4:
            [aMapArray addObject:@"obj/obj_team1"];
            [aMapArray addObject:@"obj/obj_team2"];
            [aMapArray addObject:@"obj/obj_team3"];
            [aMapArray addObject:@"obj/obj_team4"];
            
           // if (aMapArray == availableMapArray) {
           // }
            break;
    }
}

- (IBAction)showPrefs:(id)sender
{
    [prefsPanel center];
    [prefsPanel makeKeyAndOrderFront:sender];
}

- (IBAction)setCheckForUpdatePref:(id)sender
{
    [preferences setObject:[NSString stringWithFormat:@"%d", [autoUpdateCheck state]] forKey:@"autoUpdateCheck"];
}

- (void)netWorkDefaults
{
    [setNetPort setDoubleValue:12203];
    [netPortLabel setIntValue:12203];

    [setRconPass setStringValue:@"Please Use More Than 6 Characters"];

    [setMaxPlayers setIntValue:8];
    [maxPlayersLabel setStringValue:@"8"];

    [setMinPing setIntValue:0];
    [minPingLabel setStringValue:@"0"];

    [setMaxPing setIntValue:0];
    [maxPingLabel setStringValue:@"0"];

    [setMaxReconnect setIntValue:8];
    [maxReconnectLabel setStringValue:@"8"];

    [setGameSpy setState:NSOnState];
    [showInGSCServerList setState:NSOnState];
    [isOnlineServer setState:NSOnState];
    [onlineServer1 setStringValue:@""];
    [onlineServer2 setStringValue:@""];
    [onlineServer3 setStringValue:@""];
    
    [onlineServer1 setEnabled:NO];
    [onlineServer2 setEnabled:NO];
    [onlineServer3 setEnabled:NO];
    [setGameSpy setEnabled:YES];
}

- (void)serverDefaults
{
    [setJoinTime setIntValue:0];
    [joinTimeLabel setStringValue:@"0"];

    [setRespawnTime setIntValue:15];
    [respwanTimeLabel setStringValue:@"15"];

    [setSpectateTime setIntValue:300];
    [spectateTimeLabel setStringValue:@"300"];

    [setKickTime setIntValue:300];
    [kickTimeLabel setStringValue:@"300"];

    [setMuteMessages setIntValue:4];
    [muteMessagesLabel setStringValue:@"4"];

    [setUnmuteTime setIntValue:10];
    [unmuteTimeLabel setStringValue:@"10"];

    [setDiffMapVersion setState:NSOffState];
    
    [enableAutoKick setState:NSOnState];
    [banListArray removeAllObjects];
    [self setBanListString];
    [bannedList reloadData];
    // set buttons
    [addIPButton setEnabled:YES];
    [removeIPButton setEnabled:NO];
    
    [ipAddress1 setIntValue:0];
    [ipAddress2 setIntValue:0];
    [ipAddress3 setIntValue:0];
    [ipAddress4 setIntValue:0];
}

- (void)gameDefaults
{
    [setFragLimit setIntValue:50];
    [fragLimitLabel setStringValue:@"50"];

    [setTimeLimit setIntValue:15];
    [timeLimitLabel setStringValue:@"15"];

    [setRoundLimit setIntValue:15];
    [roundLimitLabel setStringValue:@"15"];
    
    [setCaptureLimit setIntValue:10];
    [captureLimitLabel setStringValue:@"10"];

    [gravityLabel setStringValue:@"800"];
    [botsLabel setStringValue:@"0"];

    [setAllowVoting setState:NSOnState];
    [setAllowCheating setState:NSOffState];
    [setForceBalance setState:NSOffState];
    [setFriendlyFire setState:NSOffState];
    [setSpectateOwn setState:NSOnState];
    
    [teamKillWarn setIntValue:1];
    [teamKillKick setIntValue:2];
    
    [dropHealthPack setState:NSOnState];
    [enableRealism setState:NSOnState];
}

- (void)generalDefaults
{
    [serverName setStringValue:@"Mac OS X power server"];
    [serverNameLabel setStringValue:[serverName stringValue]];
    [serverLocation setStringValue:@"Earth, Universe"];
    [serverHours setStringValue:@"weekdays 24 hours"];
    [adminName setStringValue:@"Major Tom"];
    [adminEmail setStringValue:@"mohrocks@majortom.org"];
    [enableServMess setState:NSOnState];
    [servMessTime setIntValue:4];
    [servMessWait setIntValue:8];
    [servMessText setStringValue:@"Welcome to Mac OS X Power server.\nNo spawn- or typekilling!\nThe admin is always right!\nPlease get our maps from www.maps.org.\n"];
    [servMessTime setEnabled:YES];
    [servMessWait setEnabled:YES];
    [servMessText setEnabled:YES];
    [leadMessEnabled setState:NSOnState];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
// initialise all when the app launched
{
    autoStartFile=NO;
    appLaunchFinished=NO;
    
    // console greeting
    NSLog(CONSOLEGREETING);
    
    // initialize the spinners
    [spinner setStyle:NSProgressIndicatorSpinningStyle];
    [spinner setDisplayedWhenStopped:NO];
    [spinner stopAnimation:self]; // stop the progress indicator

    [self initMapArrays];
    banListArray = [[NSMutableArray alloc] init];

    // disable menu items
    [stopMenuItem setEnabled: NO];
    [mapMenuItem setEnabled: NO];
    [talkMenuItem setEnabled: NO];
    [kickMenuItem setEnabled: NO];
    [banMenuItem setEnabled: NO];

    // get preferences from prefs file
    if ([preferences objectForKey:@"gameAppPath"] == nil) {
        [gameFolder setStringValue: DEF_GAMEAPPPATH];
        [preferences setObject: DEF_GAMEAPPPATH forKey:@"gameAppPath"];
    } else {
        [gameFolder setStringValue:[preferences objectForKey:@"gameAppPath"]]; // get the game app folder
    }
    
    if ([preferences objectForKey:@"autoUpdateCheck"] == nil) {
        [autoUpdateCheck setState: NSOnState];
        [preferences setObject:@"1" forKey:@"autoUpdateCheck"];
    } else {
        [autoUpdateCheck setState:[[preferences objectForKey:@"autoUpdateCheck"] isEqualToString:@"1"]];
    }
    
    // get server ID from prefs
    if ([preferences objectForKey:@"serverID"] == nil) {
        [preferences setObject:@"" forKey:@"serverID"]; // put a blank one in user prefs
    }
    
    [self setDefaultRotation];

    currentFileName = [[NSMutableString alloc] init];
    c_serverName = [[NSMutableString alloc] init];
    c_serverLocation = [[NSMutableString alloc] init];
    c_serverHours = [[NSMutableString alloc] init];
    c_adminName = [[NSMutableString alloc] init];
    c_adminEmail = [[NSMutableString alloc] init];
    c_setRconPass = [[NSMutableString alloc] init];
    c_servMessText = [[NSMutableString alloc] init];
    c_onlineServer1 = [[NSMutableString alloc] init];
    c_onlineServer2 = [[NSMutableString alloc] init];
    c_onlineServer3 = [[NSMutableString alloc] init];
    
    serverEdited = NO;
    [self setDocumentCurrentState];

    // get window positions from prefs
    [mainWindow setFrameUsingName:@"winMain"];
    [managementWindow setFrameUsingName:@"winManagement"];
    
    // check if this version has expired
    NSCalendarDate *myDate = [NSCalendarDate EXPIRYDATE timeZone:[NSTimeZone localTimeZone]];
    NSTimeInterval interval = [myDate timeIntervalSinceNow];

    if (interval < 0) { // this version has expired
        int button = NSRunAlertPanel(ALE_EXPIRED1, ALE_EXPIRED2, ALE_UPDATENOW, ALE_QUITBUTTON, nil);
        if (button == NSOKButton) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: DOWNLOAD_NEW_URL]];
        }
        // terminate the application
        [NSApp terminate:nil];
    }

     // check if there is a newer version
    if ([autoUpdateCheck state]) {
        [mainController checkForUpdate];
    }
    
    [banListArray removeAllObjects];
    [self setBanListString];
    
    // if we have a filename in the title, we'll open that file now.
    if ([[mainWindow title] isEqualToString:EMPTYWNDWTITLE]) {
       // NSLog(@"Niks openen! %@", [mainWindow title]);
    } else {
        //NSLog(@"Wel openen! %@", [mainWindow title]);
        [self loadServerConfig:[mainWindow title]];
    }
    
    [mainController updateApplicationBadge:0]; // remove the application icon badge
    
    if ([self checkCurrentGameFolder]) { // check if current gamefolder is OK
        if (autoStartFile) { // if an Autostart file was opened, start auto-launch thread.
            autoStartFile=NO;
            NSLog(@"Auto-launching now.");
            [launchController launchGameInit];
        }
    }
    
    //NSLog(@"FINISHED LAUNCH");
    appLaunchFinished=YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
// stuff to do before the app is quit
{    
    [self checkForChangedDocument];

    // save window positions in prefs
    [mainWindow saveFrameUsingName:@"winMain"];
    [managementWindow saveFrameUsingName:@"winManagement"];

    // remove the server config file
    NSMutableString *configFilePath = [[NSMutableString alloc] initWithString:[[gameFolder stringValue] stringByAppendingString: CONFIGFILENAME]]; // set the config filename

    NSFileManager * manager = [NSFileManager defaultManager];
    [manager removeFileAtPath:configFilePath handler:nil]; // remove configfile
    
    [mainController updateApplicationBadge:0]; // remove the application icon badge
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
// stuff to do when the user double clicks on a server config or drags a server config file onto the dock icon
{           
    if (appLaunchFinished) {   
        [self loadServerConfig:filename];
    } else { // launch is not finished yet, we'll set the filename in the window title
             // (quick and dirty) so it will be opened as soon as the app has finished launching.
        // NSLog(@"NOT FINISHED LAUNCHING");
        [mainWindow setTitle:filename];
    }
    return YES;
}

- (void)initMapArrays
{
    // initialize the map arrays
    availableMapArray = [[NSMutableArray alloc] init];
    selectedMapArray = [[NSMutableArray alloc] init];
}

- (void)getMapsFromDisk
// gets the map names from the game folder
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    [availableMapArray removeAllObjects]; // clear the maplist
    [self defaultMapArray: availableMapArray]; // set default maps

    NSFileManager * manager = [NSFileManager defaultManager];

    // set up the task launcher
    NSString * mapDirName = BASEDIRNAME; // maps directory
    NSMutableString * openCommand = [[NSMutableString alloc] init];

    if ([manager fileExistsAtPath: UNZIP_PATH]) { // if unzip exists
        [openCommand setString: UNZIP_PATH];
    } else { // use the bundled unzip command
        NSLog(@"/usr/bin/unzip is not found, trying local unzip command!");
        NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
        [openCommand setString: [thisBundle pathForResource:@"unzip" ofType:@""]];
    }
    
    NSString * currentFolder = [gameFolder stringValue]; // current gameFolder
    NSString * completeMapsPath = [currentFolder stringByAppendingString : mapDirName]; // game folder path including maps directory
    NSMutableArray * arguments = [NSMutableArray array]; // set the arguments array
    [arguments addObject:@"-Z"];
    [arguments addObject:@"-1"];

    // get the file list from the current directory
    NSArray * fileList = [manager directoryContentsAtPath:completeMapsPath];

    // traverse the file list and look for map files
    NSEnumerator * e = [fileList objectEnumerator];
    id cur;
    int counter=0;
    
    while (cur = [e nextObject]) { // start traversing the file list
        NSString * currentFile = [fileList objectAtIndex:counter];
        counter++;
       // NSLog(@"file: %@", currentFile);
        
        if (([[currentFile lowercaseString] hasSuffix:@".pk3"]) &&
            (![[currentFile lowercaseString] hasPrefix:@"pak"])) { // skip the fucking pak files

            [arguments addObject: currentFile]; // the file that will be unzipped

            // unzip the current file
            NSTask * unzip = [[NSTask alloc] init]; // set up a task to launch
            NSPipe * fromPipe = [NSPipe pipe]; // set up output pipe
            NSFileHandle * handle = [fromPipe fileHandleForReading]; // connect a file handle to the pipe

            [unzip setCurrentDirectoryPath: completeMapsPath]; // set the task options
            [unzip setLaunchPath: openCommand];
            [unzip setArguments: arguments];
            [unzip setStandardOutput: fromPipe]; // set the stdout pipe
            [unzip launch]; // launch the unzip command

            NSString * allTheText = [[NSString alloc] initWithData:[handle readDataToEndOfFile] encoding:NSASCIIStringEncoding]; // put the outputdata into an ASCII string
            
            // analyse the outputdata string line by line
            NSString * thisLine; // this holds the current line
            NSEnumerator *lines = [[allTheText componentsSeparatedByString:@"\n"] objectEnumerator];
            
            while (thisLine = [lines nextObject]) { // traverse the lines
               // NSLog(@"line: %@", thisLine);
                if ([[thisLine lowercaseString] hasSuffix:@".bsp"]) { // is it a mapfile?
                    NSArray * mapFileName = [thisLine componentsSeparatedByString:@"/"]; // chop up the line
                    // is it in /maps?
                    if ([[[mapFileName objectAtIndex:0] lowercaseString] isEqualToString:@"maps"]) {
                        // 1=FFA 2=TeamMatch 3=RoundBased 4=Objective 5=TOW 6=liberation
                        switch ([[gameType selectedItem] tag]) {
                            case 1:
                            case 2:
                            case 3:
                                if ([[[mapFileName objectAtIndex:1] lowercaseString] isEqualToString:@"dm"]) {
                                    NSMutableString * mapName = [[NSMutableString alloc] initWithString:[mapFileName objectAtIndex:1]];
                                    [mapName appendString:@"/"];
                                    [mapName appendString:[mapFileName objectAtIndex:2]];
                                    [availableMapArray addObject:
                                        [mapName substringToIndex:[mapName length]-4]]; // put mapname in the list without .bsp extension
                                }
                                break;
                            case 4:
                                if ([[[mapFileName objectAtIndex:1] lowercaseString] isEqualToString:@"obj"]) {
                                    NSMutableString * mapName = [[NSMutableString alloc] initWithString:[mapFileName objectAtIndex:1]];
                                    [mapName appendString:@"/"];
                                    [mapName appendString:[mapFileName objectAtIndex:2]];
                                    [availableMapArray addObject:
                                        [mapName substringToIndex:[mapName length]-4]]; // put mapname in the list without .bsp extension
                                }
                            case 5:
                                if (([[[mapFileName objectAtIndex:1] lowercaseString] isEqualToString:@"obj"]) && ([[[mapFileName objectAtIndex:1] lowercaseString] hasSuffix:@"_tow"])) {
                                    NSMutableString * mapName = [[NSMutableString alloc] initWithString:[mapFileName objectAtIndex:1]];
                                    [mapName appendString:@"/"];
                                    [mapName appendString:[mapFileName objectAtIndex:2]];
                                    [availableMapArray addObject:
                                        [mapName substringToIndex:[mapName length]-4]]; // put mapname in the list without .bsp extension
                                }
                                break;
                            case 6:
                                if (([[[mapFileName objectAtIndex:1] lowercaseString] isEqualToString:@"lib"]) && ([[[mapFileName objectAtIndex:1] lowercaseString] hasSuffix:@"_lib"])) {
                                    NSMutableString * mapName = [[NSMutableString alloc] initWithString:[mapFileName objectAtIndex:1]];
                                    [mapName appendString:@"/"];
                                    [mapName appendString:[mapFileName objectAtIndex:2]];
                                    [availableMapArray addObject:
                                        [mapName substringToIndex:[mapName length]-4]]; // put mapname in the list without .bsp extension
                                }
                                break;
                        }
                    }
                }
            }

            [arguments removeObjectAtIndex:2]; // remove the file name from arguments           
        }
    }

    [self refreshAvailableTableTitle];
    [pool release];
}

- (IBAction)browseForGameFolder:(id)sender
// browse dialog to find the game
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    // set up the file manager
    NSArray * fileTypes = nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];

    // set up the options for the "file-open" panel
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES]; // user must select a directory
    [panel setAllowsMultipleSelection:NO]; // user can only select one

    NSString * currentFolder = [gameFolder stringValue]; // remember current directory

    // open the "file open" panel
    int result = [panel runModalForDirectory:[gameFolder stringValue]
                                        file:nil
                                       types:fileTypes];
    // check what the user has done
    if (result == NSOKButton) { // the user hits the OK button
        NSArray * filesToOpen = [panel filenames]; // array of chosen files
        NSString * gameFolderPath = [filesToOpen objectAtIndex:0]; // chosen folder
        [gameFolder setStringValue: gameFolderPath]; // set the current game folder.
        [preferences setObject:[gameFolder stringValue] forKey:@"gameAppPath"]; // put it in user prefs
    } else { // the user hits the cancel button
        [gameFolder setStringValue: currentFolder]; // put original path back
    }

    // check if current folder contains the game
    [self checkCurrentGameFolder];
    [pool release];
}

- (BOOL)checkCurrentGameFolder
// checks if game folder is valid
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    NSString * gameAppName = GAMEAPPNAME; // game app file

    BOOL correctFolder = NO;
    int appPermissions = 0;
    NSString * currentFolder = [gameFolder stringValue]; // remember current directory
    NSString * completeGamePath = [currentFolder stringByAppendingString : gameAppName]; // game folder path including filename
    NSFileManager * manager = [NSFileManager defaultManager];

    // check if game app exists and is correct file type and creator
    correctFolder = ([manager fileExistsAtPath: completeGamePath]);
    NSDictionary * attributesDic = [manager fileAttributesAtPath: completeGamePath traverseLink:YES];
    appPermissions = [attributesDic filePosixPermissions];

    // set texts and buttons according to the correctness of the chosen directory
    if (correctFolder) { // check if the correct folder was chosen
        if (appPermissions == 493) { // check if it is an executable
            [gameFolderText setStringValue: PRF_GAMEFOLDER1];
            [gameFolderText setTextColor: [NSColor blackColor]];
            [launchButton setEnabled: YES];
            [launchMenuItem setEnabled: YES]; // enable the launch menu item
            [statusMessage setStringValue: GEN_READYLAUNCH]; // set statusmessage
            [statusMessage setTextColor: [NSColor blackColor]];

            // set the map list editor buttons
            [addButton setEnabled : YES];
            [downButton setEnabled : YES];
            [gameType setEnabled : YES];
            [removeButton setEnabled : YES];
            [upButton setEnabled : YES];
            [refreshButton setEnabled : YES];
            [defaultButton setEnabled : YES];

            [self getMapsFromDisk]; // read maps for this directory
        } else { // the gameApp hasn't got the right permissions
            NSBeep();
            correctFolder=NO;
            [gameFolderText setStringValue: PRF_GAMEFOLDER1];
            [gameFolderText setTextColor: [NSColor redColor]];
            [launchButton setEnabled: NO];
            [launchMenuItem setEnabled: NO];
            [statusMessage setStringValue: GEN_NOVALIDEXE]; // set statusmessage
            [statusMessage setTextColor: [NSColor redColor]];

            // set the map list editor buttons
            [addButton setEnabled: NO];
            [downButton setEnabled: NO];
            [gameType setEnabled: NO];
            [removeButton setEnabled: NO];
            [upButton setEnabled: NO];
            [refreshButton setEnabled: NO];
            [defaultButton setEnabled: NO];

            [availableMapArray removeAllObjects]; // clear the maplist
            [self refreshAvailableTableTitle];
            
            int button = NSRunAlertPanel(ALE_NOTEXECUTABLE1, ALE_NOTEXECUTABLE2, ALE_YESBUTTON, ALE_NOBUTTON, ALE_ONLINEHELP, nil);
            if (button == NSOKButton) { // try to fix the permissions
                NSMutableDictionary *posixPermissions = [NSMutableDictionary dictionary];
                [posixPermissions setDictionary:[manager fileAttributesAtPath: completeGamePath
                                                                 traverseLink:NO]];
                [posixPermissions setObject:[NSNumber numberWithInt:493] forKey:@"NSFilePosixPermissions"];
                BOOL ok = [manager changeFileAttributes:posixPermissions atPath: completeGamePath];
                
                if (ok && [manager isExecutableFileAtPath: completeGamePath]) { // is it executable now?
                    NSBeep();
                    NSRunAlertPanel(ALE_NOTEXEC_FIXED3, ALE_NOTEXEC_FIXED4, ALE_OKBUTTON, nil, nil);
                    [gameFolderText setStringValue: PRF_GAMEFOLDER1];
                    [gameFolderText setTextColor: [NSColor blackColor]];
                    [launchButton setEnabled: YES];
                    [launchMenuItem setEnabled: YES]; // enable the launch menu item
                    [statusMessage setStringValue: GEN_READYLAUNCH]; // set statusmessage
                    [statusMessage setTextColor: [NSColor blackColor]];
                    
                    // set the map list editor buttons
                    [addButton setEnabled : YES];
                    [downButton setEnabled : YES];
                    [gameType setEnabled : YES];
                    [removeButton setEnabled : YES];
                    [upButton setEnabled : YES];
                    [refreshButton setEnabled : YES];
                    [defaultButton setEnabled : YES];
                    
                    [self getMapsFromDisk]; // read maps for this directory
                } else { // executable has not been fixed
                    NSBeep();
                    int button = NSRunAlertPanel(ALE_NOTEXEC_FIXED1, ALE_NOTEXEC_FIXED2, ALE_ONLINEHELP, ALE_CANCELBUTTON, nil);
                    if (button == NSOKButton) { // show online help
                        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_EXECFIX_FAIL_URL]];
                    }
                }
            } else {
                if (button == -1) { // show online help
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_EXECUTABLE_URL]];
                }
            }
        }
    } else { // the game app cannot be found
        [gameFolderText setStringValue: PRF_GAMEFOLDER2];
        [gameFolderText setTextColor: [NSColor redColor]];
        [launchButton setEnabled: NO];
        [launchMenuItem setEnabled: NO];
        [statusMessage setStringValue: GEN_NOVALIDFOLDER]; // set statusmessage
        [statusMessage setTextColor: [NSColor redColor]];

        // set the map list editor buttons
        [addButton setEnabled : NO];
        [downButton setEnabled : NO];
        [gameType setEnabled : NO];
        [removeButton setEnabled : NO];
        [upButton setEnabled : NO];
        [refreshButton setEnabled : NO];
        [defaultButton setEnabled : NO];

        [availableMapArray removeAllObjects]; // clear the maplist
        [self refreshAvailableTableTitle];
        
        NSBeep();
        int button = NSRunAlertPanel(PRF_YOUNEEDEXE1, PRF_YOUNEEDEXE2, ALE_ONLINEHELP, ALE_CANCELBUTTON, nil);
        if (button == NSOKButton) { // show online help
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_DOWNLOAD_EXE_URL]];
        }
        
        // [self showPrefs:self];
    }
    
    return correctFolder;
    
    [pool release];
}

- (IBAction)saveFile:(id)sender
{
    [self saveServerConfig:NO];
}

- (IBAction)saveAsFile:(id)sender
{
    [self saveServerConfig:YES];
}

- (IBAction)loadFile:(id)sender
{
    [self loadServerConfig:@""];
}

- (void)loadServerConfig:(NSString *)filename
// this method opens a file open dialog unless a filename has already been given
{ 
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    //NSLog(@"Opening filename: %@", filename);
    
    // check if the server is currently running
    if ([[statusMessage stringValue] isEqualToString:GEN_RUNNING]) {
        NSBeep();
        int button = NSRunAlertPanel(ALE_CANNOTOPENFILE1, ALE_CANNOTOPENFILE2, ALE_OKBUTTON, ALE_ONLINEHELP, nil);
        if (button == NSCancelButton) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_CANTOPENFILE_URL]];
        }
    } else { // we can now open the file
        [self checkForChangedDocument]; // ask to save if something has been edited
        NSMutableString *selectedFile = [[NSMutableString alloc] init];
    
        if ([filename isEqualToString:@""]) { // if we have to filename yet
            // set up the file manager
            NSArray * fileTypes = [OPEN_EXTENSION componentsSeparatedByString:@" "];
            NSOpenPanel * panel = [NSOpenPanel openPanel];

            // set up the options for the "file-open" panel
            [panel setCanChooseFiles:YES]; // user must select a file
            [panel setCanChooseDirectories:NO];
            [panel setAllowsMultipleSelection:NO]; // user can only select one

            // open the "file open" panel
            int result = [panel runModalForDirectory:[currentFileName stringByDeletingLastPathComponent] file:nil types:fileTypes];
           // int result = [panel beginSheetForDirectory:[currentFileName stringByDeletingLastPathComponent] file:nil types:fileTypes modalForWindow:mainWindow modalDelegate:self didEndSelector: contextInfo:NULL];
    
            // check what the user has done
            if (result == NSOKButton) { // the user hits the OK button
                NSArray * filesToOpen = [panel filenames]; // array of chosen files
                [selectedFile setString:[filesToOpen objectAtIndex:0]]; // chosen file
            } else {
                [selectedFile setString:@""]; // just in case, empty the string
            }
        } else {
            [selectedFile setString:filename]; // get the filename from the parameter
        }
    
        NSFileManager * manager = [NSFileManager defaultManager];
        BOOL fileExists=NO;
        BOOL isDir=NO;
        
        fileExists=[manager fileExistsAtPath:selectedFile isDirectory:&isDir];
        
        if (fileExists && !isDir && ![selectedFile isEqualToString:@""]) { // if the file exists and is no directory, we're gonna open it.
            // open the file and read the dictionary
            NSDictionary *serverDict = [[NSDictionary alloc] initWithContentsOfFile: selectedFile];
            
            if (serverDict == nil) { // the file is damaged
                NSBeep();
                int button = NSRunAlertPanel(ALE_FILEDAMAGED1, ALE_FILEDAMAGED2, ALE_CANCELBUTTON, ALE_ONLINEHELP, nil);
                if (button == NSCancelButton) {
                    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_FILEDAMAGED_URL]];
                }
            } else { // the dictionary plist is OK, let's read stuff
                [currentFileName setString:selectedFile];
                
                // general tab items
                [serverName setStringValue:[serverDict objectForKey:@"serverName"]];
                [serverNameLabel setStringValue:[serverName stringValue]];
                [serverLocation setStringValue:[serverDict objectForKey:@"serverLocation"]];
                [serverHours setStringValue:[serverDict objectForKey:@"serverHours"]];
                [adminName setStringValue:[serverDict objectForKey:@"adminName"]];
                [adminEmail setStringValue:[serverDict objectForKey:@"adminEmail"]];
                [servMessTime setStringValue:[serverDict objectForKey:@"servMessTime"]];
                [servMessWait setStringValue:[serverDict objectForKey:@"servMessWait"]];
                [servMessText setStringValue:[serverDict objectForKey:@"servMessText"]];
                [enableServMess setState:[[serverDict objectForKey:@"enableServMess"] isEqualToString:@"1"]];
                [leadMessEnabled setState:[[serverDict objectForKey:@"leadMessEnabled"] isEqualToString:@"1"]];

                // network tab items
                [maxPingLabel setStringValue:[serverDict objectForKey:@"maxPingLabel"]];
                [setMaxPing setIntValue:[maxPingLabel intValue]];
                [maxPlayersLabel setStringValue:[serverDict objectForKey:@"maxPlayersLabel"]];
                [setMaxPlayers setIntValue:[maxPlayersLabel intValue]];
                [maxReconnectLabel setStringValue:[serverDict objectForKey:@"maxReconnectLabel"]];
                [setMaxReconnect setIntValue:[maxReconnectLabel intValue]];
                [minPingLabel setStringValue:[serverDict objectForKey:@"minPingLabel"]];
                [setMinPing setIntValue:[minPingLabel intValue]];
                [netPortLabel setStringValue:[serverDict objectForKey:@"netPortLabel"]];
                [setNetPort setIntValue:[netPortLabel intValue]];
                [setGameSpy setState:[[serverDict objectForKey:@"setGameSpy"] isEqualToString:@"1"]];
                [showInGSCServerList setState:[[serverDict objectForKey:@"showInGSCServerList"] isEqualToString:@"1"]];
                [setRconPass setStringValue:[serverDict objectForKey:@"setRconPass"]];
                
                [isOnlineServer setState:[[serverDict objectForKey:@"isOnlineServer"] isEqualToString:@"1"]];
                [onlineServer1 setStringValue:[serverDict objectForKey:@"onlineServer1"]];
                [onlineServer2 setStringValue:[serverDict objectForKey:@"onlineServer2"]];
                [onlineServer3 setStringValue:[serverDict objectForKey:@"onlineServer3"]];
                [self enableOnlineServerItems];
                
                // server tab items
                [joinTimeLabel setStringValue:[serverDict objectForKey:@"joinTimeLabel"]];
                [setJoinTime setIntValue:[joinTimeLabel intValue]];
                [respwanTimeLabel setStringValue:[serverDict objectForKey:@"respawnTimeLabel"]];
                [setRespawnTime setIntValue:[respwanTimeLabel intValue]];
                [spectateTimeLabel setStringValue:[serverDict objectForKey:@"spectateTimeLabel"]];
                [setSpectateTime setIntValue:[spectateTimeLabel intValue]];
                [kickTimeLabel setStringValue:[serverDict objectForKey:@"kickTimeLabel"]];
                [setKickTime setIntValue:[kickTimeLabel intValue]];
                [muteMessagesLabel setStringValue:[serverDict objectForKey:@"muteMessagesLabel"]];
                [setMuteMessages setIntValue:[muteMessagesLabel intValue]];
                [unmuteTimeLabel setStringValue:[serverDict objectForKey:@"unmuteTimeLabel"]];
                [setUnmuteTime setIntValue:[unmuteTimeLabel intValue]];
                [setDiffMapVersion setState:[[serverDict objectForKey:@"setDiffMapVersion"] isEqualToString:@"1"]];
                [enableAutoKick setState:[[serverDict objectForKey:@"enableAutoKick"] isEqualToString:@"1"]];
                [banListArray setArray:[serverDict objectForKey:@"banList"]];
                [self setBanListString];
                [bannedList reloadData];
                
                // game tab items
                [fragLimitLabel setStringValue:[serverDict objectForKey:@"fragLimitLabel"]];
                [setFragLimit setIntValue:[fragLimitLabel intValue]];
                [timeLimitLabel setStringValue:[serverDict objectForKey:@"timeLimitLabel"]];
                [setTimeLimit setIntValue:[timeLimitLabel intValue]];
                [roundLimitLabel setStringValue:[serverDict objectForKey:@"roundLimitLabel"]];
                [setRoundLimit setIntValue:[roundLimitLabel intValue]];
                [captureLimitLabel setStringValue:[serverDict objectForKey:@"captureLimitLabel"]];
                [setCaptureLimit setIntValue:[captureLimitLabel intValue]];
                [gravityLabel setStringValue:[serverDict objectForKey:@"gravityLabel"]];
                [botsLabel setStringValue:[serverDict objectForKey:@"botsLabel"]];
                [setAllowVoting setState:[[serverDict objectForKey:@"setAllowVoting"] isEqualToString:@"1"]];
                [setForceBalance setState:[[serverDict objectForKey:@"setForceBalance"] isEqualToString:@"1"]];
                [setFriendlyFire setState:[[serverDict objectForKey:@"setFriendlyFire"] isEqualToString:@"1"]];
                [setSpectateOwn setState:[[serverDict objectForKey:@"setSpectateOwn"] isEqualToString:@"1"]];
                [setAllowCheating setState:[[serverDict objectForKey:@"setAllowCheating"] isEqualToString:@"1"]];
                [teamKillWarn setStringValue:[serverDict objectForKey:@"teamKillWarn"]];
                [teamKillKick setStringValue:[serverDict objectForKey:@"teamKillKick"]];
                [dropHealthPack setState:[[serverDict objectForKey:@"dropHealthPack"] isEqualToString:@"1"]];
                [enableRealism setState:[[serverDict objectForKey:@"enableRealism"] isEqualToString:@"1"]];

                // maps tab items
                [selectedMapArray setArray:[serverDict objectForKey:@"selectedMaps"]];
                [gameType selectItemAtIndex:[[serverDict objectForKey:@"gameType"] intValue]];
                [self refreshSelectedTableTitle];

                serverEdited = NO;
                [self setDocumentCurrentState];

                [mainWindow setTitleWithRepresentedFilename:selectedFile]; // set window title
                
                // check if we need to auto-start
                autoStartFile=([[selectedFile lowercaseString] rangeOfString:AUTOSTARTNAME].location!=NSNotFound);
            
                // check if file was saved with another GSC version
                if (![[serverDict objectForKey:@"gscversion"] isEqualToString:GSC_VERSION]) {
                    // NSLog(@"OLD file version");
                    serverEdited = YES;
                    NSBeep();
                    int button = NSRunAlertPanel(ALE_OLDFILEVERS1, ALE_OLDFILEVERS2, ALE_OKBUTTON, ALE_ONLINEHELP, nil);
                    if (button == NSCancelButton) {
                        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:HELP_OLDFILEVER_URL]];
                    }
                }
                
                // check if the rconpass isn't too short
                [mainController checkRconPass:self];
            }
        }
    }
    
    [pool release];
}

- (IBAction)newFile:(id)sender
{
    [self checkForChangedDocument]; // ask to save if something has been edited
    
    [self setDefaultRotation];
    [gameType selectItemAtIndex:0];
    
    [self netWorkDefaults];
    [self serverDefaults];
    [self gameDefaults];
    [self generalDefaults];

    [self setDocumentCurrentState];
    [currentFileName setString:@""];
    serverEdited = NO;
    
    [mainWindow setTitle:EMPTYWNDWTITLE];
}

- (void)saveServerConfig:(BOOL)saveAs
// this saves the current server config
{
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    int actionSelection=0; // 0=do nothing, 1=save in new file, 2=save in current file
    NSSavePanel * panel = [NSSavePanel savePanel]; // set up the file manager
    NSMutableString *filePath = [[NSMutableString alloc] init];
    
    if (saveAs || ([currentFileName length] == 0)) { // user wants to "save as"
        // set up the options for the "file-save" panel
        [panel setCanSelectHiddenExtension:NO];

        // open the "file save" panel
        int result = [panel runModalForDirectory:[currentFileName stringByDeletingLastPathComponent] file:DEFAULT_FNAME];
        if (result == NSOKButton) { // the user has chosen to save the file
            actionSelection=1; // save in new file
            [filePath setString:[panel filename]]; // set the filename to save to
            if (![filePath hasSuffix:SAVE_EXTENSION]) { // if there is no extension
                [filePath appendString:SAVE_EXTENSION]; // append extension
            }
        } else {
            actionSelection=0; // do nothing
            [filePath setString:@"/"];
        }
    } else {
        actionSelection=2; // save in current file
        filePath = currentFileName;
    }

    // start saving the file
    if (actionSelection != 0 ) { // user wants to save
        [currentFileName setString:filePath];
        
        // create a dictionary of all the current game server settings
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        
        // version information
        [configDict setObject:GSC_VERSION forKey:@"gscversion"];

        // general tab items
        [configDict setObject:[serverName stringValue] forKey:@"serverName"];
        [configDict setObject:[serverLocation stringValue] forKey:@"serverLocation"];
        [configDict setObject:[serverHours stringValue] forKey:@"serverHours"];
        [configDict setObject:[adminName stringValue] forKey:@"adminName"];
        [configDict setObject:[adminEmail stringValue] forKey:@"adminEmail"];
        [configDict setObject:[servMessTime stringValue] forKey:@"servMessTime"];
        [configDict setObject:[servMessWait stringValue] forKey:@"servMessWait"];
        [configDict setObject:[servMessText stringValue] forKey:@"servMessText"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [enableServMess state]] forKey:@"enableServMess"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [leadMessEnabled state]] forKey:@"leadMessEnabled"];

        // network tab items
        [configDict setObject:[maxPingLabel stringValue] forKey:@"maxPingLabel"];
        [configDict setObject:[maxPlayersLabel stringValue] forKey:@"maxPlayersLabel"];
        [configDict setObject:[maxReconnectLabel stringValue] forKey:@"maxReconnectLabel"];
        [configDict setObject:[minPingLabel stringValue] forKey:@"minPingLabel"];
        [configDict setObject:[netPortLabel stringValue] forKey:@"netPortLabel"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [setGameSpy state]] forKey:@"setGameSpy"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [showInGSCServerList state]] forKey:@"showInGSCServerList"];
        [configDict setObject:[setRconPass stringValue] forKey:@"setRconPass"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [isOnlineServer state]] forKey:@"isOnlineServer"];
        [configDict setObject:[onlineServer1 stringValue] forKey:@"onlineServer1"];
        [configDict setObject:[onlineServer2 stringValue] forKey:@"onlineServer2"];
        [configDict setObject:[onlineServer3 stringValue] forKey:@"onlineServer3"];

        // server tab items
        [configDict setObject:[joinTimeLabel stringValue] forKey:@"joinTimeLabel"];
        [configDict setObject:[respwanTimeLabel stringValue] forKey:@"respawnTimeLabel"];
        [configDict setObject:[spectateTimeLabel stringValue] forKey:@"spectateTimeLabel"];
        [configDict setObject:[kickTimeLabel stringValue] forKey:@"kickTimeLabel"];
        [configDict setObject:[muteMessagesLabel stringValue] forKey:@"muteMessagesLabel"];
        [configDict setObject:[unmuteTimeLabel stringValue] forKey:@"unmuteTimeLabel"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [setDiffMapVersion state]] forKey:@"setDiffMapVersion"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [enableAutoKick state]] forKey:@"enableAutoKick"];   
        [configDict setObject:banListArray forKey:@"banList"];

        // game tab items
        [configDict setObject:[fragLimitLabel stringValue] forKey:@"fragLimitLabel"];
        [configDict setObject:[timeLimitLabel stringValue] forKey:@"timeLimitLabel"];
        [configDict setObject:[roundLimitLabel stringValue] forKey:@"roundLimitLabel"];
        [configDict setObject:[captureLimitLabel stringValue] forKey:@"captureLimitLabel"];
        [configDict setObject:[gravityLabel stringValue] forKey:@"gravityLabel"];
        [configDict setObject:[botsLabel stringValue] forKey:@"botsLabel"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [setAllowVoting state]] forKey:@"setAllowVoting"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [setForceBalance state]] forKey:@"setForceBalance"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [setFriendlyFire state]] forKey:@"setFriendlyFire"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [setSpectateOwn state]] forKey:@"setSpectateOwn"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [setAllowCheating state]] forKey:@"setAllowCheating"];
        [configDict setObject:[teamKillWarn stringValue] forKey:@"teamKillWarn"];
        [configDict setObject:[teamKillKick stringValue] forKey:@"teamKillKick"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [dropHealthPack state]] forKey:@"dropHealthPack"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [enableRealism state]] forKey:@"enableRealism"];

        // maps tab items
        [configDict setObject:selectedMapArray forKey:@"selectedMaps"];
        [configDict setObject:[NSString stringWithFormat:@"%d", [gameType indexOfSelectedItem]] forKey:@"gameType"];

        if (![configDict writeToFile:filePath atomically:YES]) { // write the dictionary to file
            NSBeep(); // file did not save!
//            NSLog(@"Could not save settings file!");
        } else { // save is successful
            serverEdited = NO;
            [self setDocumentCurrentState];
            [mainWindow setTitleWithRepresentedFilename:currentFileName];
        }
    }
    
    [pool release];
}

- (IBAction)setServMessEnabled:(id)sender
// this method responds when the user enables server messages
{
    serverEdited = YES;
    if ([enableServMess intValue] == 1) {
        [servMessTime setEnabled:YES];
        [servMessWait setEnabled:YES];
        [servMessText setEnabled:YES];
    } else {
        [servMessTime setEnabled:NO];
        [servMessWait setEnabled:NO];
        [servMessText setEnabled:NO];
    }
}

- (IBAction)setAutoKickEnabled:(id)sender
    // this method responds when the user enables server messages
{
    serverEdited = YES;
    if ([enableAutoKick intValue] == 1) {
        [addIPButton setEnabled:([banListArray count] < MAXBANLISTSIZE)];
        [removeIPButton setEnabled:([banListArray count] > 0)];
        [ipAddress1 setEnabled:YES];
        [ipAddress2 setEnabled:YES];
        [ipAddress3 setEnabled:YES];
        [ipAddress4 setEnabled:YES];
    } else {
        [addIPButton setEnabled:NO];
        [removeIPButton setEnabled:NO];
        [ipAddress1 setEnabled:NO];
        [ipAddress2 setEnabled:NO];
        [ipAddress3 setEnabled:NO];
        [ipAddress4 setEnabled:NO];
    }
}

- (IBAction)setOnlineServersEnabled:(id)sender
// this method responds when the user enables online services
{
    serverEdited = YES;
    [self enableOnlineServerItems];
}

-(void)enableOnlineServerItems
{
    if ([isOnlineServer intValue] == 1) {
        [onlineServer1 setEnabled:NO];
        [onlineServer2 setEnabled:NO];
        [onlineServer3 setEnabled:NO];
        [setGameSpy setEnabled:YES];
        [showInGSCServerList setEnabled:YES];
    } else {
        [onlineServer1 setEnabled:NO];
        [onlineServer2 setEnabled:NO];
        [onlineServer3 setEnabled:NO];
        [setGameSpy setEnabled:NO];
        [showInGSCServerList setEnabled:NO];
    }
}

- (IBAction)documentEdited:(id)sender
// this is called by all items that can trigger it
{
    serverEdited = YES;
}

- (BOOL)checkDocumentEdited
// check if document has been edited by user
{
    // general tab items
    if (![c_serverName isEqualToString:[serverName stringValue]]) {serverEdited=YES;}
    if (![c_serverLocation isEqualToString:[serverLocation stringValue]]) {serverEdited=YES;}
    if (![c_serverHours isEqualToString:[serverHours stringValue]]) {serverEdited=YES;}
    if (![c_adminName isEqualToString:[adminName stringValue]]) {serverEdited=YES;}
    if (![c_adminEmail isEqualToString:[adminEmail stringValue]]) {serverEdited=YES;}
    if (c_servMessTime != [servMessTime intValue]) {serverEdited=YES;}
    if (c_servMessWait != [servMessWait intValue]) {serverEdited=YES;}  
    if (![c_servMessText isEqualToString:[servMessText stringValue]]) {serverEdited=YES;}

    // network tab items
    if (c_setMaxPing != [setMaxPing intValue]) {serverEdited=YES;}
    if (c_setMaxPlayers != [setMaxPlayers intValue]) {serverEdited=YES;}
    if (c_setMaxReconnect != [setMaxReconnect intValue]) {serverEdited=YES;}
    if (c_setMinPing != [setMinPing intValue]) {serverEdited=YES;}
    if (c_setNetPort != [setNetPort intValue]) {serverEdited=YES;}
    if (![c_setRconPass isEqualToString:[setRconPass stringValue]]) {serverEdited=YES;}
    if (![c_onlineServer1 isEqualToString:[onlineServer1 stringValue]]) {serverEdited=YES;}
    if (![c_onlineServer2 isEqualToString:[onlineServer2 stringValue]]) {serverEdited=YES;}
    if (![c_onlineServer3 isEqualToString:[onlineServer3 stringValue]]) {serverEdited=YES;}

    // server tab items
    if (c_setJoinTime != [setJoinTime intValue]) {serverEdited=YES;}
    if (c_setRespawnTime != [setRespawnTime intValue]) {serverEdited=YES;}
    if (c_setSpectateTime != [setSpectateTime intValue]) {serverEdited=YES;}
    if (c_setKickTime != [setKickTime intValue]) {serverEdited=YES;}
    if (c_setMuteMessages != [setMuteMessages intValue]) {serverEdited=YES;}
    if (c_setUnmuteTime != [setUnmuteTime intValue]) {serverEdited=YES;}

    // game tab items
    if (c_setFragLimit != [setFragLimit intValue]) {serverEdited=YES;}
    if (c_setTimeLimit != [setTimeLimit intValue]) {serverEdited=YES;}
    if (c_setRoundLimit != [setRoundLimit intValue]) {serverEdited=YES;}
    if (c_setCaptureLimit != [setCaptureLimit intValue]) {serverEdited=YES;}
    if (c_gravityLabel != [gravityLabel intValue]) {serverEdited=YES;}
    if (c_teamKillWarn != [teamKillWarn intValue]) {serverEdited=YES;}
    if (c_teamKillKick != [teamKillKick intValue]) {serverEdited=YES;}
    
    if (serverEdited) {
        return YES;
    } else {
        return NO;
    }
}

- (void)setDocumentCurrentState
// save current state to see if changed later on
{
    // general tab items
    [c_serverName setString:[serverName stringValue]];
    [c_serverLocation setString:[serverLocation stringValue]];
    [c_serverHours setString:[serverHours stringValue]];
    [c_adminName setString:[adminName stringValue]];
    [c_adminEmail setString:[adminEmail stringValue]];
    c_servMessTime = [servMessTime intValue];
    c_servMessWait = [servMessWait intValue];
    [c_servMessText setString:[servMessText stringValue]];

    // network tab items
    c_setMaxPing = [setMaxPing intValue];
    c_setMaxPlayers = [setMaxPlayers intValue];
    c_setMaxReconnect = [setMaxReconnect intValue];
    c_setMinPing = [setMinPing intValue];
    c_setNetPort = [setNetPort intValue];
    [c_setRconPass setString:[setRconPass stringValue]];
    [c_onlineServer1 setString:[onlineServer1 stringValue]];
    [c_onlineServer2 setString:[onlineServer2 stringValue]];
    [c_onlineServer3 setString:[onlineServer3 stringValue]];

    // server tab items
    c_setJoinTime = [setJoinTime intValue];
    c_setRespawnTime = [setRespawnTime intValue];
    c_setSpectateTime = [setSpectateTime intValue];
    c_setKickTime = [setKickTime intValue];
    c_setMuteMessages = [setMuteMessages intValue];
    c_setUnmuteTime = [setUnmuteTime intValue];

    // game tab items
    c_setFragLimit = [setFragLimit intValue];
    c_setTimeLimit = [setTimeLimit intValue];
    c_setRoundLimit = [setRoundLimit intValue];
    c_setCaptureLimit = [setCaptureLimit intValue];
    c_gravityLabel = [gravityLabel intValue];
    c_teamKillWarn = [teamKillWarn intValue];
    c_teamKillKick = [teamKillKick intValue];
}

- (void) checkForChangedDocument
// this method checks if the document was changed by the user
{
    // check if document changed
    if ([self checkDocumentEdited]) {
        NSBeep();
        int button = NSRunAlertPanel(ALE_SAVECHANGES1, ALE_SAVECHANGES2, ALE_YESBUTTON, ALE_NOBUTTON, nil);
        if (button == NSOKButton) { // yes, save it
            [self saveServerConfig:NO]; // do a save
        }
    }
}

- (void)getBanlistFromBanlistString
// this method puts the items from the banlistString into the banist
{
    // NSLog(@"Getting banlist from string...");
    
    [banListArray removeAllObjects];
    [banListArray addObjectsFromArray:[[bannedListString stringValue] componentsSeparatedByString:@" "]];
    
    serverEdited = YES;
    [self setBanListString];
    
    // display list
    [bannedList reloadData];
    [bannedList selectRow:([banListArray count]-1) byExtendingSelection:NO];
    [bannedList scrollRowToVisible:[banListArray count]-1];
    // set buttons
    [addIPButton setEnabled:([banListArray count] < MAXBANLISTSIZE)];
    [removeIPButton setEnabled:([banListArray count] > 0)];
}

@end
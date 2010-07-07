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

#import <Cocoa/Cocoa.h>

@interface LaunchController : NSWindowController
{
    // *** needed for server config file
    // general tab items
    IBOutlet id serverName;
    IBOutlet id serverLocation;
    IBOutlet id serverHours;
    IBOutlet id adminName;
    IBOutlet id adminEmail;
    IBOutlet id servMessEnabled;
    IBOutlet id servMessTime;
    IBOutlet id servMessWait;
    IBOutlet id servMessText;
    IBOutlet id leadMessEnabled;

    // network tab items
    IBOutlet id showInGSCServerList;
    IBOutlet id setGameSpy;
    IBOutlet id setMaxPing;
    IBOutlet id setMaxPlayers;
    IBOutlet id setMaxReconnect;
    IBOutlet id setMinPing;
    IBOutlet id setNetPort;
    IBOutlet id setRconPass;
    IBOutlet id isOnlineServer;
    IBOutlet id onlineServer1;
    IBOutlet id onlineServer2;
    IBOutlet id onlineServer3;

    // server tab items
    IBOutlet id setJoinTime;
    IBOutlet id setRespawnTime;
    IBOutlet id setSpectateTime;
    IBOutlet id setKickTime;
    IBOutlet id setDiffMapVersion;
    IBOutlet id setMuteMessages;
    IBOutlet id setUnmuteTime;
    IBOutlet id enableAutoKick;
    IBOutlet id ipAddress1;
    IBOutlet id ipAddress2;
    IBOutlet id ipAddress3;
    IBOutlet id ipAddress4;
    IBOutlet id bannedListString;

    // game tab items
    IBOutlet id setFragLimit;
    IBOutlet id setTimeLimit;
    IBOutlet id setRoundLimit;
    IBOutlet id setCaptureLimit;
    IBOutlet id setAllowVoting;
    IBOutlet id setForceBalance;
    IBOutlet id setFriendlyFire;
    IBOutlet id setSpectateOwn;
    IBOutlet id setAllowCheating;
    IBOutlet id setGravity;
    IBOutlet id botsLabel;
    IBOutlet id teamKillWarn;
    IBOutlet id teamKillKick;
    IBOutlet id dropHealthPack;
    IBOutlet id enableRealism;

    // maps tab items
    IBOutlet id gameType;
    IBOutlet id mapRotation;
    IBOutlet id availableMapList;

    // **** other
    IBOutlet id gameFolder;
    IBOutlet id launchButton;
    IBOutlet id spinner;
    IBOutlet id statusMessage;
    IBOutlet id launchMenuItem;
    IBOutlet id stopMenuItem;
    IBOutlet id fileNewMenuItem;
    IBOutlet id fileOpenMenuItem;
    IBOutlet id fileRecentMenuItem;
    IBOutlet id kickMenuItem;
    IBOutlet id banMenuItem;
    IBOutlet id talkMenuItem;
    IBOutlet id mapMenuItem;
    IBOutlet id quitMenuItem;
    IBOutlet id prefsMenuItem;
    IBOutlet id checkUpdateMenuItem;
    IBOutlet id mainWindow;

    // management window
    IBOutlet id manSpinner;
    IBOutlet id managementWindow;
    IBOutlet id manServerName;
    IBOutlet id manServerStatus;
    IBOutlet id manCurrentMap;
    IBOutlet id noOfPlayers;
    IBOutlet id playerTable;
    IBOutlet id rconCommandText;
    IBOutlet id currentServMess;
    IBOutlet id mapSelector;
    IBOutlet id mapSelectorButton;
    IBOutlet id manSetBotsLabel;
    IBOutlet id manQuitButton;
    
    // controller connections
    IBOutlet id mainController;
    IBOutlet id docController;
    
    NSTask *myTask;
    NSPipe *toPipe;
    NSPipe *fromPipe;
    NSFileHandle *toTask;
    NSFileHandle *fromTask;
    IBOutlet NSTextView *theText;

    NSMutableArray *playerArray;
    BOOL gameIsRunning;
    BOOL weHaveToQuit;
    BOOL banListChanged;
}
- (IBAction)launchGame:(id)sender;
- (void)launchGameInit;
- (void)launchGameThread;

- (void)gotData:(NSNotification *)notification;
- (IBAction)manKickPlayer:(id)sender;
- (IBAction)manBanPlayer:(id)sender;
- (void)autoKickPlayers;
- (void)talkToServer:(NSString *)command;
- (void)pollServer;

- (void)showManagementWindow;
- (void)hideManagementWindow;

- (IBAction)quitGame:(id)sender;
- (IBAction)rconCommand:(id)sender;
- (IBAction)changeMap:(id)sender;
- (IBAction)changeMapButtonControl:(id)sender;

- (IBAction)changeBotsAmount:(id)sender;
- (IBAction)checkBotsValueAction:(id)sender;
- (void)checkBotsValue;
- (BOOL)gameProcessRuns;

- (void)gscServerSignOn;
- (void)gscServerSignOff;
@end

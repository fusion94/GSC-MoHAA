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

@interface DocController : NSObject
{    
    // preferences items
    IBOutlet id gameFolder;
    IBOutlet id gameFolderText;
    IBOutlet id autoUpdateCheck;
    
    // general tab items
    IBOutlet id serverName;
    IBOutlet id serverLocation;
    IBOutlet id serverHours;
    IBOutlet id adminName;
    IBOutlet id adminEmail;
    IBOutlet id enableServMess;
    IBOutlet id servMessTime;
    IBOutlet id servMessWait;
    IBOutlet id servMessText;
    IBOutlet id leadMessEnabled;
    
    // network tab items
    IBOutlet id maxPingLabel;
    IBOutlet id maxPlayersLabel;
    IBOutlet id maxReconnectLabel;
    IBOutlet id minPingLabel;
    IBOutlet id netPortLabel;
    IBOutlet id setMaxPing;
    IBOutlet id setMaxPlayers;
    IBOutlet id setMaxReconnect;
    IBOutlet id setMinPing;
    IBOutlet id setNetPort;
    IBOutlet id setRconPass;
    IBOutlet id setGameSpy;
    IBOutlet id showInGSCServerList;
    IBOutlet id isOnlineServer;
    IBOutlet id onlineServer1;
    IBOutlet id onlineServer2;
    IBOutlet id onlineServer3;

    // server tab items
    IBOutlet id joinTimeLabel;
    IBOutlet id respwanTimeLabel;
    IBOutlet id spectateTimeLabel;
    IBOutlet id kickTimeLabel;
    IBOutlet id muteMessagesLabel;
    IBOutlet id unmuteTimeLabel;
    IBOutlet id setJoinTime;
    IBOutlet id setRespawnTime;
    IBOutlet id setSpectateTime;
    IBOutlet id setKickTime;
    IBOutlet id setMuteMessages;
    IBOutlet id setUnmuteTime;
    IBOutlet id setDiffMapVersion;
    IBOutlet id enableAutoKick;
    IBOutlet id ipAddress1;
    IBOutlet id ipAddress2;
    IBOutlet id ipAddress3;
    IBOutlet id ipAddress4;
    IBOutlet id addIPButton;
    IBOutlet id removeIPButton;
    IBOutlet id bannedList;
    IBOutlet id bannedListString;

    // game tab items
    IBOutlet id fragLimitLabel;
    IBOutlet id timeLimitLabel;
    IBOutlet id roundLimitLabel;
    IBOutlet id captureLimitLabel;
    IBOutlet id setFragLimit;
    IBOutlet id setTimeLimit;
    IBOutlet id setRoundLimit;
    IBOutlet id setCaptureLimit;
    IBOutlet id setAllowVoting;
    IBOutlet id setForceBalance;
    IBOutlet id setFriendlyFire;
    IBOutlet id setSpectateOwn;
    IBOutlet id setAllowCheating;
    IBOutlet id gravityLabel;
    IBOutlet id botsLabel;
    IBOutlet id teamKillWarn;
    IBOutlet id teamKillKick;
    IBOutlet id dropHealthPack;
    IBOutlet id enableRealism;

    // maps tab items
    IBOutlet id addButton;
    IBOutlet id downButton;
    IBOutlet id gameType;
    IBOutlet id removeButton;
    IBOutlet id upButton;
    IBOutlet id availableMaps;
    IBOutlet id selectedMaps;
    IBOutlet id refreshButton;
    IBOutlet id defaultButton;
    IBOutlet id mapRotation;
    IBOutlet id availableMapList;

    //other
    IBOutlet id spinner;
    IBOutlet id launchButton;
    IBOutlet id launchMenuItem;
    IBOutlet id fileRecentMenuItem;
    IBOutlet id stopMenuItem;
    IBOutlet id kickMenuItem;
    IBOutlet id banMenuItem;
    IBOutlet id talkMenuItem;
    IBOutlet id mapMenuItem;
    IBOutlet id statusMessage;
    IBOutlet id serverNameLabel;
    
    // controller connections
    IBOutlet id mainController;
    IBOutlet id launchController;

    // windows
    IBOutlet id prefsPanel;
    IBOutlet id mainWindow;
    IBOutlet id managementWindow;
    
    NSMutableArray *availableMapArray;
    NSMutableArray *selectedMapArray;
    
    NSMutableArray *banListArray;

    NSMutableString *currentFileName;
    BOOL serverEdited;

    // ****** used to set current state ******
    // general tab items
    NSMutableString *c_serverName;
    NSMutableString *c_serverLocation;
    NSMutableString *c_serverHours;
    NSMutableString *c_adminName;
    NSMutableString *c_adminEmail;
    NSMutableString *c_servMessText;
    int c_servMessTime;
    int c_servMessWait;

    // network tab items
    int c_setMaxPing;
    int c_setMaxPlayers;
    int c_setMaxReconnect;
    int c_setMinPing;
    int c_setNetPort;
    NSMutableString *c_setRconPass;
    NSMutableString *c_onlineServer1;
    NSMutableString *c_onlineServer2;
    NSMutableString *c_onlineServer3;

    // server tab items
    int c_setJoinTime;
    int c_setRespawnTime;
    int c_setSpectateTime;
    int c_setKickTime;
    int c_setMuteMessages;
    int c_setUnmuteTime;

    // game tab items
    int c_setFragLimit;
    int c_setTimeLimit;
    int c_setRoundLimit;
    int c_setCaptureLimit;
    int c_gravityLabel;
    int c_teamKillWarn;
    int c_teamKillKick;
    
    // other
    BOOL appLaunchFinished;
    BOOL autoStartFile;
}
- (IBAction)addMap:(id)sender;
- (IBAction)moveMapDown:(id)sender;
- (IBAction)moveMapUp:(id)sender;
- (IBAction)refreshMaps:(id)sender;
- (IBAction)removeMap:(id)sender;
- (IBAction)selectGameType:(id)sender;

- (IBAction)defaultMaps:(id)sender;
- (IBAction)setNetworkDefaults:(id)sender;
- (IBAction)setServerDefaults:(id)sender;
- (IBAction)setGameDefaults:(id)sender;

- (IBAction)addIP:(id)sender;
- (IBAction)removeIP:(id)sender;

- (IBAction)documentEdited:(id)sender;
- (IBAction)setServMessEnabled:(id)sender;
- (IBAction)setAutoKickEnabled:(id)sender;
- (IBAction)setOnlineServersEnabled:(id)sender;
- (void)enableOnlineServerItems;

- (void)getMapsFromDisk;
- (void)initMapArrays;
- (void)refreshSelectedTableTitle;
- (void)refreshAvailableTableTitle;
- (void)setDefaultRotation;
- (void)netWorkDefaults;
- (void)serverDefaults;
- (void)gameDefaults;
- (void)generalDefaults;
- (void)defaultMapArray: (NSMutableArray *)aMapArray;
- (BOOL)checkCurrentGameFolder;
- (void)setBanListString;

- (IBAction)saveFile:(id)sender;
- (IBAction)saveAsFile:(id)sender;
- (IBAction)loadFile:(id)sender;
- (IBAction)newFile:(id)sender;

- (IBAction)showPrefs:(id)sender;
- (IBAction)browseForGameFolder:(id)sender;
- (IBAction)setCheckForUpdatePref:(id)sender;

- (void)saveServerConfig:(BOOL)saveAs;
- (void)loadServerConfig:(NSString *)filename;

- (BOOL)checkDocumentEdited;
- (void)setDocumentCurrentState;
- (void)checkForChangedDocument;

- (void)getBanlistFromBanlistString;
@end

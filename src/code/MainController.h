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

@interface MainController : NSObject
{
    // about box items
    IBOutlet id aboutBox;
    IBOutlet id appTitle;
    IBOutlet id versionString;
    IBOutlet id expiryString;
    IBOutlet id disclaimString;

    // general tab items
    IBOutlet id servMessTime;
    IBOutlet id servMessWait;
    IBOutlet id servMessText;
    IBOutlet id serverName;
    IBOutlet id serverLocation;
    IBOutlet id adminName;
    
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

    // game tab items
    IBOutlet id fragLimitLabel;
    IBOutlet id timeLimitLabel;
    IBOutlet id roundLimitLabel;
    IBOutlet id captureLimitLabel;
    IBOutlet id gravityLabel;
    IBOutlet id botsLabel;
    IBOutlet id setFragLimit;
    IBOutlet id setTimeLimit;
    IBOutlet id setRoundLimit;
    IBOutlet id setCaptureLimit;
    IBOutlet id teamKillWarn;
    IBOutlet id teamKillKick;
    
    // other items
    IBOutlet id serverNameLabel;
}

- (IBAction)paypalDonate:(id)sender;
- (IBAction)launchHelpURL:(id)sender;
- (IBAction)checkForUpdate:(id)sender;
- (IBAction)showAboutBox:(id)sender;
- (IBAction)setSliderBars:(id)sender;
- (IBAction)checkServMess:(id)sender;
- (IBAction)checkRconPass:(id)sender;
- (IBAction)checkGeneralFields:(id)sender;
- (void)checkServMessNow;

- (void)updateApplicationBadge:(int)number;
- (void)checkForUpdate;
@end

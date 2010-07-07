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

// messages
#define CONSOLEGREETING		@"Game Server Configulator (MoHAA) greets those who are playing Medal of Honor!"
#define CONSOLE_HEADER		@"Medal of Honor server run by Game Server Configulator - MoHAA.\nCopyright �2003-2006 P-Edge media\nCopyright �2006-2010 Damage Studios\n\nThe \"mohaa_server executable\" is copyrighted by Aspyr Media inc.\n"
#define CONFIG_HEADER1		@"// Created by Game Server Configulator -MoHAA-]\n// (C) Copyright 2003-2006 P-Edge media\n(C) Copyright 2006-2010 Damage Studios\n"
#define CONFIG_HEADER2      @"// For more info visit http://damagestudios.net\n\n"
#define SERVMESSGREETING	@"*** this server is run by GSC for Mac OS X! (http://damagestudios.net) ***"

// about window
#define ABO_VERS		@"version "
#define GSC_TITLE		@"Game Server Configulator\n(MoHAA)"
#define COPYRIGHT_TEXT		@"Copyright �2003-2006 P-Edge media\nCopyright �2006-2010 Damage Studios"
#define ABOUT_DISCLAIM          @"The \"mohaa_server\" executable is copyrighted by Aspyr Media inc. and EA Games."

// general window
#define GEN_LAUNCHING		@"Launching the server..."
#define GEN_RUNNING		@"The server is running."
#define GEN_NOTRUNNING		@"The server is not running."
#define GEN_READYLAUNCH		@"The server is ready for launch."
#define GEN_NOVALIDFOLDER	@"No valid game folder in preferences."
#define GEN_NOVALIDEXE		@"No valid executable in game folder."
#define GEN_SERVMESSERR		@"Please enter messages here or disable server messages!"

// server management window
#define MAN_SELECTMAP		@"select a map..."
#define MAN_WAITMESSAGE		@"[Waiting to send first message.]"
#define MAN_GOINGDOWN1		@"\nPlease wait, server is going down...\n"
#define MAN_GOINGDOWN2		@"Please wait, server is going down..."
#define MAN_WAITFORSTART	@"Please wait while the game starts..."
#define MAN_CONNECTED		@"%d player(s) and %d bot(s)"
#define MAN_MAPCHANGING		@"Changing the current map..."
#define MAN_PLAYERKICKED	@"Kicked: %@"
#define MAN_AUTOKICKED          @"AUTOKICKED: %@"
#define MAN_PLAYERBANNED        @"BANNED: %@"
#define MAN_MESSAGESENT		@"A message was sent by the admin."
#define MAN_BOTSCHANGING	@"Changed the amount of bots..."
#define MAN_CONNECTMAIN1        @"\nConnecting to the main GSC server... "
#define MAN_CONNECTMAIN2        @"succesful!\n\n"
#define MAN_CONNECTMAIN3        @"failed!\n\n"
#define MAN_CONNECTMAIN4        @"no reply from the server!\n\n"
#define MAN_KICKEDPL            @"------- KICKED!"
#define MAN_AUTOKICKEDPL        @"--- AUTOKICKED!"

// map window
#define MAP_INROTATION		@"Maps in rotation (%d)"
#define MAP_AVAILABLE		@"Available maps (%d)"

// prefs window
#define PRF_GAMEFOLDER1		@"Medal of Honor game folder:"
#define PRF_GAMEFOLDER2		@"mohaa_server is not here:"
#define PRF_YOUNEEDEXE1         @"Dedicated server executable missing"
#define PRF_YOUNEEDEXE2         @"The dedicated server executable \"mohaa_server\" is not in the selected game folder."

// in game messages
#define GAM_USERKICKED		@"say ---- The admin is kicking %@..."
#define GAM_AUTOKICKED          @"say ---- %@ is AUTO-KICKED because %@ is a banned IP address."
#define GAM_USERBANNED          @"say ---- %@ is BANNED from this server by the admin and will be kicked within 30 seconds."
#define GAM_MAPCHANGED		@"say ---- The admin is changing the current map..."
#define GAM_GOINGDOWN		@"say ---- The admin is quitting the server..."
#define GAM_BOTSCHANGED		@"say ---- The admin has changed the number of bots to %@..."
#define GAM_LEADPLAYER1		@"say ---- %@ is in the lead with %d kills!!"
#define GAM_LEADPLAYER2		@"say ---- %@ are leading with %d kills."
#define GAM_LASTPLAYER1		@"say ---- %@ is last with %d kills..."
#define GAM_LASTPLAYER2		@"say ---- %@ are behind with %d kills..."

// alerts
#define ALE_OKBUTTON		@"OK"
#define	ALE_YESBUTTON		@"Yes"
#define	ALE_NOBUTTON		@"No"
#define ALE_CANCELBUTTON	@"Cancel"
#define ALE_QUITBUTTON		@"Quit"
#define ALE_ONLINEHELP		@"Online help"
#define ALE_UPDATENOW		@"Update now"
#define ALE_NEVERMIND		@"Never mind"
#define ALE_CORRECT		@"Zero bots"

#define ALE_CANNOTLAUNCH1	@"Cannot launch the server"
#define ALE_CANNOTLAUNCH2	@"The dedicated server process is already running. Please quit the process."
#define ALE_CANNOTLAUNCH3	@"The server configuration file could not be saved."
#define ALE_PLAYERSCNNCT1	@"There are players connected"
#define ALE_PLAYERSCNNCT2	@"Are you sure you want to kill the server?"

#define ALE_EXPIRED1		@"This version has expired"
#define ALE_EXPIRED2		@"Please update to the latest version."
#define ALE_NOUPDATECHECK1	@"Could not check for updates"
#define ALE_NOUPDATECHECK2	@"The software server is not responding."
#define ALE_ILLCHECKLATER	@"I'll try later"
#define ALE_NOUPDATEFOUND1	@"No updates found"
#define ALE_NOUPDATEFOUND2	@"You already have the latest version (%@) of %@."
#define ALE_NEWVERSFOUND1	@"Software update found"
#define ALE_NEWVERSFOUND2	@"Would you like to download version %@?"

#define ALE_SAVECHANGES1	@"Server configuration changed"
#define ALE_SAVECHANGES2	@"Would you like to save your changes?"

#define ALE_NOTEXECUTABLE1	@"mohaa_server is not executable"
#define ALE_NOTEXECUTABLE2	@"Would you like GSC to try and fix this?"
#define ALE_NOTEXEC_FIXED1      @"The fix failed"
#define ALE_NOTEXEC_FIXED2      @"Please consult our online help."
#define ALE_NOTEXEC_FIXED3      @"The fix worked"
#define ALE_NOTEXEC_FIXED4      @"Your mohaa_server is now executable."

#define ALE_CANNOTADDIP1        @"This IP address can not be banned"
#define ALE_CANNOTADDIP2        @"Please consult our online help."
#define ALE_CANNOTADDIP3        @"This IP address is already banned."

#define ALE_OLDFILEVERS1        @"This file was saved with an older GSC version"
#define ALE_OLDFILEVERS2        @"Missing settings will be set to current values."
#define ALE_CANNOTOPENFILE1     @"Cannot open this file"
#define ALE_CANNOTOPENFILE2     @"You cannot open a file while the server is running."
#define ALE_FILEDAMAGED1        @"This file is damaged"
#define ALE_FILEDAMAGED2        @"The file cannot be opened."

#define ALE_BANTHISPLAYER1      @"This IP (%@) will be banned"
#define ALE_BANTHISPLAYER2      @"The player is named: %@\nClick OK to ban this player immediately."

#define ALE_RCONPASS1           @"Your rcon password is too short"
#define ALE_RCONPASS2           @"Please us a password of more than 6 characters."

#define ALE_BOTSPLAYERS1        @"More bots than players"
#define ALE_BOTSPLAYERS2        @"The amount of bots (%d) is equal to, or bigger than the maximum amount of players (%d). Your server will be FULL with bots and no additional players will be able to join."
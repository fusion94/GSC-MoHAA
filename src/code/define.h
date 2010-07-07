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

// prefs foo bar goof
#define preferences	[NSUserDefaults standardUserDefaults]
#define GSC_APPNAME	[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleName"]
#define GSC_VERSION	[[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"]
#define EXPIRYDATE      dateWithYear:2010 month:12 day:31 hour:23 minute:59 second:59
#define EXPIRY_DATE     @"This version will expire on December 31st 2010"
#define VERSIONDICTKEY	@"gscmoh"
#define EMPTYWNDWTITLE  @"GSC MoHAA"
#define MAXMAPLISTSIZE	50
#define MAXBANLISTSIZE  999
#define MAXAUTOGENPLYR  12

// files and directories
#define APPICONIMAGE    @"gscmoh_app.icns"
#define BASEDIRNAME	@"/main"
#define CONFIGFILENAME 	@"/main/gscmoh.cfg"
#define GAMEPARAMETER1 	@"+exec gscmoh.cfg"
#define GAMEPARAMETER2 	@"+set dedicated 2"
#define GAMEPARAMETER3  @"+set net_port %d"
#define GAMEPARAMETER4 	@""
#define GAMEPARAMETER5 	@""
#define GAMEAPPNAME	@"/mohaa_server"
#define DEF_GAMEAPPPATH	@"/Applications/Medal of Honor"
#define UNZIP_PATH	@"/usr/bin/unzip"
#define SAVE_EXTENSION  @".gscmoh"
#define OPEN_EXTENSION  @"gscmoh"
#define DEFAULT_FNAME   @"Untitled Server.gscmoh"
#define AUTOSTARTNAME   @"autostart.gscmoh"

// server runtime settings
#define RUNPOLLWAITTIME	30
#define HEARTBEATTIME   28800
#define MAXCONSOLESIZE	16384
#define STATUSLINELEN   72

// help URL's
#define HELP_SAVE_FILES_URL	@"http://damagestudios.net/help/gscmohaa/"
#define HELP_QUIT_FIRST_URL	@"http://damagestudios.net/help/gscmohaa/"
#define PAYPAL_DONATE_URL	@"http://damagestudios.net/donate"
#define ONLINE_MANUAL_URL	@"http://damagestudios.net/help/gscmohaa/"
#define HELP_EXECUTABLE_URL	@"http://damagestudios.net/help/gscmohaa/"
// new urls added below
#define HELP_ADDIP_URL          @"http://damagestudios.net/"
#define HELP_OLDFILEVER_URL     @"http://damagestudios.net/"
#define HELP_CANTOPENFILE_URL   @"http://damagestudios.net/"
#define HELP_EXECFIX_FAIL_URL   @"http://damagestudios.net/"
#define HELP_RCONPASS_URL       @"http://damagestudios.net/"
#define HELP_FILEDAMAGED_URL    @"http://damagestudios.net/"

//Warning Box for missing Dedicated Servers
#define HELP_DOWNLOAD_EXE_URL   @"http://damagestudios.net/help/gscmohaa/"

// internal URL's
#define VERSION_CHECK_URL	@"http://damagestudios.net/versioncheck.xml"
#define DOWNLOAD_NEW_URL	@"http://damagestudios.net/"
#define GSC_SERV_SIGNON         @"http://damagestudios.net/"
#define GSC_SERV_SIGNOFF        @"http://damagestudios.net/"
//#define GSC_SERV_SIGNON         @"http://damagestudios.net/gsc/gscservers/submit.php?mode=signon&id=%@&hostname=%@&adminname=%@&gametype=%@&location=%@&netport=%d"
//#define GSC_SERV_SIGNOFF        @"http://damagestudios.net/gsc/gscservers/submit.php?mode=signoff&id=%@&hostname=%@&adminname=%@&gametype=%@&location=%@&netport=%d"
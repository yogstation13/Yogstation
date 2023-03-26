

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
#define ROLE_SYNDICATE			"Syndicate"
#define ROLE_TRAITOR			"Traitor"
#define ROLE_OPERATIVE			"Operative"
#define ROLE_CLOWNOP			"Clown Operative"
#define ROLE_CHANGELING			"Changeling"
#define ROLE_WIZARD				"Wizard"
#define ROLE_RAGINMAGES			"Ragin Mages"
#define ROLE_BULLSHITMAGES		"Bullshit Mages"
#define ROLE_MALF				"Malf AI"
#define ROLE_REV				"Revolutionary"
#define ROLE_REV_HEAD			"Head Revolutionary"
#define ROLE_ALIEN				"Xenomorph"
#define ROLE_PAI				"pAI"
#define ROLE_CULTIST			"Cultist"
#define ROLE_HERETIC			"Heretic"
#define ROLE_BLOB				"Blob"
#define ROLE_NINJA				"Space Ninja"
#define ROLE_MONKEY				"Monkey"
#define ROLE_ABDUCTOR			"Abductor"
#define ROLE_REVENANT			"Revenant"
#define ROLE_DEVIL				"Devil"
#define ROLE_SERVANT_OF_RATVAR	"Servant of Ratvar"
#define ROLE_BROTHER			"Blood Brother"
#define ROLE_BRAINWASHED		"Brainwashed Victim"
#define ROLE_HIVE				"Hivemind Host"
#define ROLE_OBSESSED			"Obsessed"
#define ROLE_SENTIENCE			"Sentient Creature"
#define ROLE_MOUSE				"Mouse"
#define ROLE_MIND_TRANSFER		"Mind Transfer Potion"
#define ROLE_POSIBRAIN			"Posibrain"
#define ROLE_DRONE				"Drone"
#define ROLE_DEATHSQUAD			"Deathsquad"
#define ROLE_LAVALAND			"Lavaland"
#define ROLE_INTERNAL_AFFAIRS	"Internal Affairs Agent"
#define ROLE_FUGITIVE           "Fugitive"
#define ROLE_SHADOWLING 		"Shadowling" // Yogs
#define ROLE_VAMPIRE			"Vampire" // Yogs
#define ROLE_GANG				"gangster" // Yogs
#define ROLE_DARKSPAWN			"darkspawn" // Yogs
#define ROLE_HOLOPARASITE		"Holoparasite" // Yogs
#define ROLE_HORROR				"Eldritch Horror" // Yogs
#define ROLE_INFILTRATOR		"Infiltrator" // Yogs
#define ROLE_ZOMBIE				"Zombie"
#define ROLE_BLOODSUCKER		"Bloodsucker"
#define ROLE_VAMPIRICACCIDENT	"Vampiric Accident"
#define ROLE_BLOODSUCKERBREAKOUT	"Bloodsucker Breakout"
#define ROLE_MONSTERHUNTER		"Monster Hunter"
#define ROLE_SPACE_DRAGON		"Space Dragon"
#define ROLE_GOLEM				"Golem"
#define ROLE_SINFULDEMON		"Demon of Sin"
#define ROLE_GHOSTBEACON		"Ghost Beacon"
#define ROLE_NIGHTMARE			"Nightmare"
#define ROLE_DISEASE			"Disease"
#define ROLE_PIRATE				"Pirate"


//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
// check sql_ban_system.dm as well, that's where the job bans are located.
GLOBAL_LIST_INIT(special_roles, list(
	ROLE_TRAITOR = /datum/antagonist/traitor,
	ROLE_OPERATIVE = /datum/antagonist/nukeop,
	ROLE_CLOWNOP = /datum/antagonist/nukeop/clownop,
	ROLE_CHANGELING	= /datum/antagonist/changeling,
	ROLE_WIZARD = /datum/antagonist/wizard,
	ROLE_RAGINMAGES	= /datum/antagonist/wizard,
	ROLE_BULLSHITMAGES = /datum/antagonist/wizard,
	ROLE_MALF = /datum/antagonist/traitor/malf,
	ROLE_REV_HEAD = /datum/antagonist/rev/head,
	ROLE_ALIEN = /datum/antagonist/xeno,
	ROLE_CULTIST = /datum/antagonist/cult,
	ROLE_HERETIC = /datum/antagonist/heretic,
	ROLE_BLOB = /datum/antagonist/blob,
	ROLE_NINJA = /datum/antagonist/ninja,
	ROLE_MONKEY	= /datum/antagonist/monkey,
	ROLE_ABDUCTOR = /datum/antagonist/abductor,
	ROLE_REVENANT = /datum/antagonist/revenant,
	ROLE_DEVIL = /datum/antagonist/devil,
	ROLE_SERVANT_OF_RATVAR = /datum/antagonist/clockcult,
	ROLE_BROTHER = /datum/antagonist/brother,
	ROLE_BRAINWASHED = /datum/antagonist/brainwashed,
	ROLE_OBSESSED = /datum/antagonist/obsessed,
	ROLE_INTERNAL_AFFAIRS = /datum/antagonist/traitor/internal_affairs,
	ROLE_FUGITIVE = /datum/antagonist/fugitive,
	ROLE_SHADOWLING = /datum/antagonist/shadowling, // Yogs
	ROLE_VAMPIRE = /datum/antagonist/vampire, // Yogs
	ROLE_GANG = /datum/antagonist/gang, // Yogs
	ROLE_DARKSPAWN = /datum/antagonist/darkspawn, // Yogs
	ROLE_HOLOPARASITE = /datum/antagonist/guardian, // Yogs
	ROLE_HORROR = /datum/antagonist/horror, // Yogs
	ROLE_INFILTRATOR = /datum/antagonist/infiltrator, // Yogs
	ROLE_ZOMBIE	= /datum/antagonist/zombie,
	ROLE_BLOODSUCKER = /datum/antagonist/bloodsucker,
	ROLE_MONSTERHUNTER = /datum/antagonist/monsterhunter,
	ROLE_SPACE_DRAGON = /datum/antagonist/space_dragon,
	ROLE_GOLEM = /datum/antagonist/golem,
	ROLE_SINFULDEMON = /datum/antagonist/sinfuldemon,
	ROLE_NIGHTMARE = /datum/antagonist/nightmare,
	ROLE_DISEASE = /datum/antagonist/disease,
	ROLE_HIVE = /datum/antagonist/hivemind,
	ROLE_PIRATE = /datum/antagonist/pirate,
	ROLE_SENTIENCE = /datum/antagonist/sentient_creature
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3

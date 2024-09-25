

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
#define ROLE_VAMPIRE			"Vampire" // Yogs
#define ROLE_VAMPIRICACCIDENT	"Vampiric Accident"
#define ROLE_GANG				"gangster" // Yogs
#define ROLE_DARKSPAWN			"Darkspawn" // Yogs
#define ROLE_HOLOPARASITE		"Holoparasite" // Yogs
#define ROLE_HORROR				"Eldritch Horror" // Yogs
#define ROLE_INFILTRATOR		"Infiltrator" // Yogs
#define ROLE_ZOMBIE				"Zombie"
#define ROLE_BLOODSUCKER		"Bloodsucker"
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



GLOBAL_LIST_INIT(special_required_days, list(
	// Roundstart
	ROLE_BROTHER = 0,
	ROLE_CHANGELING = 0,
	ROLE_CLOWN_OPERATIVE = 14,
	ROLE_CULTIST = 14,
	ROLE_HERETIC = 0,
	ROLE_MALF = 0,
	ROLE_OPERATIVE = 14,
	ROLE_REV_HEAD = 14,
	ROLE_TRAITOR = 0,
	ROLE_WIZARD = 14,
	ROLE_SERVANT_OF_RATVAR = 14,
	ROLE_BLOODSUCKER = 0,
	ROLE_ASSAULT_OPERATIVE = 14,
	ROLE_DARKSPAWN = 14,

	// Midround
	ROLE_ABDUCTOR = 0,
	ROLE_ALIEN = 0,
	ROLE_BLOB = 0,
	ROLE_CHANGELING_MIDROUND = 0,
	ROLE_CYBER_POLICE = 0,
	ROLE_FUGITIVE = 0,
	ROLE_LONE_OPERATIVE = 14,
	ROLE_MALF_MIDROUND = 0,
	ROLE_NIGHTMARE = 0,
	ROLE_NINJA = 0,
	ROLE_OBSESSED = 0,
	ROLE_OPERATIVE_MIDROUND = 14,
	ROLE_REVENANT = 0,
	ROLE_SENTIENT_DISEASE = 0,
	ROLE_SLEEPER_AGENT = 0,
	ROLE_SPACE_DRAGON = 0,
	ROLE_SPIDER = 0,
	ROLE_WIZARD_MIDROUND = 14,
	ROLE_VAMPIRICACCIDENT = 0,
	ROLE_MONSTERHUNTER = 0,

	// Latejoin
	ROLE_HERETIC_SMUGGLER = 0,
	ROLE_PROVOCATEUR = 14,
	ROLE_SYNDICATE_INFILTRATOR = 0,
	ROLE_BLOODSUCKERBREAKOUT = 0,
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3

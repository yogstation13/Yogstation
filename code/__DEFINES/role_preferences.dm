

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
#define ROLE_ANTAG				"Syndicate"
#define ROLE_TRAITOR			"Traitor"
#define ROLE_OPERATIVE			"Operative"
#define ROLE_CLOWNOP			"Clown Operative"
#define ROLE_CHANGELING			"Changeling"
#define ROLE_WIZARD				"Wizard"
#define ROLE_MALF				"Malf AI"
#define ROLE_REV				"Revolutionary"
#define ROLE_REV_HEAD			"Head Revolutionary"
#define ROLE_ALIEN				"Xenomorph"
#define ROLE_PAI				"pAI"
#define ROLE_CULTIST			"Cultist"
#define ROLE_HERETIC			"Heretic"
#define ROLE_BLOB				"Blob"
#define ROLE_NINJA				"Space Ninja"
#define ROLE_ABDUCTOR			"Abductor"
#define ROLE_REVENANT			"Revenant"
#define ROLE_DEVIL				"Devil"
#define ROLE_SERVANT_OF_RATVAR	"Servant of Ratvar"
#define ROLE_BROTHER			"Blood Brother"
#define ROLE_BRAINWASHED		"Brainwashed Victim"
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
#define ROLE_DARKSPAWN			"Darkspawn" // Yogs
#define ROLE_HOLOPARASITE		"Holoparasite" // Yogs
#define ROLE_HORROR				"Eldritch Horror" // Yogs
#define ROLE_INFILTRATOR		"Infiltrator" // Yogs
#define ROLE_ZOMBIE				"Zombie"
#define ROLE_BLOODSUCKER		"Bloodsucker"
#define ROLE_MONSTERHUNTER		"Monster Hunter"
#define ROLE_SPACE_DRAGON		"Space Dragon"
#define ROLE_GOLEM				"Golem"
#define ROLE_SINFULDEMON		"Demon of Sin"
#define ROLE_GHOSTBEACON		"Ghost Beacon"
#define ROLE_NIGHTMARE			"Nightmare"
#define ROLE_DISEASE			"Disease"
#define ROLE_PIRATE				"Pirate"


/**
 * This list is used to keep track of which antag ROLE defines correlate to which antag
 * Yes, this is hardcoded, but it's faster to access than checking literally every single antag typepath for it's antag flag
 * 
 * This is used in multiple ways
 * -What antags show up under "Antagonist Positions" for the ban panel (sql_ban_system.dm)
 * -Access the min_account_age variable of the antag datum for use determining if an account is old enough to play an antag
 * 
 * An antag should be on this list if it does at least one of these things
 * -Has a significant round impact
 * -Should be possible to ban players from playing
 */
GLOBAL_LIST_INIT(special_roles, list(

	//every antag
	ROLE_ANTAG = /datum/antagonist,

	//Roundstart exclusive
	ROLE_OPERATIVE = /datum/antagonist/nukeop,
	ROLE_CLOWNOP = /datum/antagonist/nukeop/clownop,
	ROLE_DARKSPAWN = /datum/antagonist/darkspawn, // Yogs
	ROLE_MALF = /datum/antagonist/traitor/malf,
	ROLE_REV = /datum/antagonist/rev,
	ROLE_REV_HEAD = /datum/antagonist/rev/head,
	ROLE_WIZARD = /datum/antagonist/wizard,
	ROLE_CULTIST = /datum/antagonist/cult,
	ROLE_SERVANT_OF_RATVAR = /datum/antagonist/clockcult,

	//Roundstart or Midround
	ROLE_VAMPIRE = /datum/antagonist/vampire, // Yogs
	ROLE_BLOODSUCKER = /datum/antagonist/bloodsucker,
	ROLE_TRAITOR = /datum/antagonist/traitor,
	ROLE_CHANGELING	= /datum/antagonist/changeling,
	ROLE_HERETIC = /datum/antagonist/heretic,
	ROLE_BROTHER = /datum/antagonist/brother,

	//Midround exclusive
	ROLE_MONSTERHUNTER = /datum/antagonist/monsterhunter,
	ROLE_HORROR = /datum/antagonist/horror,
	ROLE_SPACE_DRAGON = /datum/antagonist/space_dragon,
	ROLE_ZOMBIE	= /datum/antagonist/zombie,
	ROLE_BLOB = /datum/antagonist/blob,
	ROLE_NINJA = /datum/antagonist/ninja,
	ROLE_REVENANT = /datum/antagonist/revenant,
	ROLE_ALIEN = /datum/antagonist/xeno,
	ROLE_NIGHTMARE = /datum/antagonist/nightmare,
	ROLE_DISEASE = /datum/antagonist/disease,
	ROLE_PIRATE = /datum/antagonist/pirate,
	ROLE_INFILTRATOR = /datum/antagonist/infiltrator,
	ROLE_ABDUCTOR = /datum/antagonist/abductor,
	ROLE_OBSESSED = /datum/antagonist/obsessed,

	ROLE_SINFULDEMON = /datum/antagonist/sinfuldemon,

	//Others
	ROLE_FUGITIVE = /datum/antagonist/fugitive,
	ROLE_HOLOPARASITE = /datum/antagonist/guardian,
	ROLE_GOLEM = /datum/antagonist/golem,
	ROLE_SENTIENCE = /datum/antagonist/sentient_creature,
	ROLE_BRAINWASHED = /datum/antagonist/brainwashed,

	//unimplemented
	ROLE_DEVIL = /datum/antagonist/devil,
	ROLE_INTERNAL_AFFAIRS = /datum/antagonist/traitor/internal_affairs
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3

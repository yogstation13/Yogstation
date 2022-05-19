/*ALL MOB-RELATED DEFINES THAT DON'T BELONG IN ANOTHER FILE GO HERE*/

//Misc mob defines

//Ready states at roundstart for mob/dead/new_player
#define PLAYER_NOT_READY 0
#define PLAYER_READY_TO_PLAY 1
#define PLAYER_READY_TO_OBSERVE 2

//Game mode list indexes
#define CURRENT_LIVING_PLAYERS	"living_players_list"
#define CURRENT_LIVING_ANTAGS	"living_antags_list"
#define CURRENT_DEAD_PLAYERS	"dead_players_list"
#define CURRENT_OBSERVERS		"current_observers_list"

//movement intent defines for the m_intent var
#define MOVE_INTENT_WALK "walk"
#define MOVE_INTENT_RUN  "run"

//Blood volumes, in cL
#define BLOOD_VOLUME_GENERIC		560 // The default amount of blood in a blooded creature, in cL, based off IRL data about humans
#define BLOOD_VOLUME_MONKEY			325 // Based on IRL data bout Chimpanzees
#define BLOOD_VOLUME_XENO			700 // Based off data from my asshole

#define BLOOD_VOLUME_SLIME_SPLIT	(2.0 * BLOOD_VOLUME_GENERIC) // Amount of blood needed by slimebois for splitting in twain

//Blood multiplers -- Multiply the original default value of blood your Carbon has with these in order to get the actual blood tiers
// i.e.	if(h.blood_volume < initial(h.blood_volume) * BLOOD_OKAY_MULTI) or whatever
//used by :living/proc/get_blood_state()
#define BLOOD_MAXIMUM_MULTI 3.6 // 360%
#define BLOOD_SAFE_MULTI 0.848	// 84.8%
#define BLOOD_OKAY_MULTI 0.6	// 60%
#define BLOOD_BAD_MULTI 0.4		// 40%
#define BLOOD_SURVIVE_MULTI 0.2	// 20%

//Blood state enums, again used by get_blood_state()
#define BLOOD_MAXIMUM 5
#define BLOOD_SAFE 4
#define BLOOD_OKAY 3
#define BLOOD_BAD 2
#define BLOOD_SURVIVE 1
#define BLOOD_DEAD 0

//Defines to get the actual volumes for these varying states
#define BLOOD_VOLUME_MAXIMUM(L)		(initial(##L.blood_volume) * BLOOD_MAXIMUM_MULTI)
#define BLOOD_VOLUME_NORMAL(L)		(initial(##L.blood_volume))
#define BLOOD_VOLUME_SAFE(L)		(initial(##L.blood_volume) * BLOOD_SAFE_MULTI)
#define BLOOD_VOLUME_OKAY(L)		(initial(##L.blood_volume) * BLOOD_OKAY_MULTI)
#define BLOOD_VOLUME_BAD(L)			(initial(##L.blood_volume) * BLOOD_BAD_MULTI)
#define BLOOD_VOLUME_SURVIVE(L)		(initial(##L.blood_volume) * BLOOD_SURVIVE_MULTI)

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_TINY 0
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3
#define MOB_SIZE_HUGE 4

//Ventcrawling defines
#define VENTCRAWLER_NONE   0
#define VENTCRAWLER_NUDE   1
#define VENTCRAWLER_ALWAYS 2

//Bloodcrawling defines
#define BLOODCRAWL 1
#define BLOODCRAWL_EAT 2

//Mob bio-types
#define MOB_ORGANIC 	"organic"
#define MOB_INORGANIC 	"inorganic"
#define MOB_ROBOTIC 	"robotic"
#define MOB_UNDEAD		"undead"
#define MOB_HUMANOID 	"humanoid"
#define MOB_BUG 		"bug"
#define MOB_BEAST		"beast"
#define MOB_EPIC		"epic" //megafauna
#define MOB_REPTILE		"reptile"
#define MOB_SPIRIT		"spirit"

//Organ defines for carbon mobs
#define ORGAN_ORGANIC   1
#define ORGAN_ROBOTIC   2

#define BODYPART_ORGANIC   1
#define BODYPART_ROBOTIC   2

#define DEFAULT_BODYPART_ICON_ORGANIC 'icons/mob/human_parts_greyscale.dmi'
#define DEFAULT_BODYPART_ICON_ROBOTIC 'icons/mob/augmentation/augments.dmi'

#define MONKEY_BODYPART "monkey"
#define ALIEN_BODYPART "alien"
#define LARVA_BODYPART "larva"
#define DEVIL_BODYPART "devil"
/*see __DEFINES/inventory.dm for bodypart bitflag defines*/

//Species ID defines
#define SPECIES_HUMAN			"human"
#define SPECIES_ETHEREAL 		"ethereal"
#define SPECIES_PLASMAMAN 		"plasmaman"
#define SPECIES_PHYTOSIAN 		"phytosian"
#define SPECIES_MOTH			"moth"
#define SPECIES_LIZARD			"lizard"
#define SPECIES_FELINID			"felinid"
#define SPECIES_SLIMEPERSON		"slimeperson"
#define SPECIES_FLY 			"fly"
#define SPECIES_PRETERNIS 		"preternis"
#define SPECIES_POLYSMORPH 		"polysmorph"

//Species bitflags, used for species_restricted. If this somehow ever gets above 23 Yogs has larger problems.

#define FLAG_HUMAN			(1<<0)
#define FLAG_ETHEREAL		(1<<1)
#define FLAG_PLASMAMAN		(1<<2)
#define	FLAG_PHYTOSIAN		(1<<3)
#define FLAG_MOTH			(1<<4)
#define FLAG_LIZARD			(1<<5)
#define FLAG_FELINID		(1<<6)
#define FLAG_SLIMEPERSON	(1<<7)
#define FLAG_FLY			(1<<8)
#define FLAG_PRETERNIS		(1<<9)
#define FLAG_POLYSMORPH		(1<<10)

/*
GLOBAL_LIST_INIT(flag2speciesid, list(
	FLAG_HUMAN = SPECIES_HUMAN,
	FLAG_ETHEREAL = SPECIES_ETHEREAL,
	FLAG_PLASMAMAN = SPECIES_PLASMAMAN,
	FLAG_PHYTOSIAN = SPECIES_PHYTOSIAN,
	FLAG_MOTH = SPECIES_MOTH,
	FLAG_LIZARD = SPECIES_LIZARD,
	FLAG_FELINID = SPECIES_FELINID,
	FLAG_SLIMEPERSON = SPECIES_SLIMEPERSON,
	FLAG_FLY = SPECIES_FLY,
	FLAG_PRETERNIS = SPECIES_PRETERNIS,
	FLAG_POLYSMORPH = SPECIES_POLYSMORPH
	))
*/

// Health/damage defines for carbon mobs
#define HUMAN_MAX_OXYLOSS 3
#define HUMAN_CRIT_MAX_OXYLOSS (SSmobs.wait/30)

#define STAMINA_REGEN_BLOCK_TIME (10 SECONDS)

#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 3 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 8 //Amount of damage applied when your body temperature passes the 460K point and you are on fire

#define COLD_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 3 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.5 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 1.5 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 3 //Amount of damage applied when the current breath's temperature passes the 120K point

//Brain Damage defines
#define BRAIN_DAMAGE_MILD 20
#define BRAIN_DAMAGE_SEVERE 100
#define BRAIN_DAMAGE_DEATH 200

#define BRAIN_TRAUMA_MILD /datum/brain_trauma/mild
#define BRAIN_TRAUMA_SEVERE /datum/brain_trauma/severe
#define BRAIN_TRAUMA_SPECIAL /datum/brain_trauma/special
#define BRAIN_TRAUMA_MAGIC /datum/brain_trauma/magic

#define TRAUMA_RESILIENCE_BASIC 1      //Curable with chems
#define TRAUMA_RESILIENCE_SURGERY 2    //Curable with brain surgery
#define TRAUMA_RESILIENCE_LOBOTOMY 3   //Curable with lobotomy
#define TRAUMA_RESILIENCE_WOUND 4    //Curable by healing the head wound
#define TRAUMA_RESILIENCE_MAGIC 5      //Curable only with magic
#define TRAUMA_RESILIENCE_ABSOLUTE 6   //This is here to stay

//Limit of traumas for each resilience tier
#define TRAUMA_LIMIT_BASIC 3
#define TRAUMA_LIMIT_SURGERY 2
#define TRAUMA_LIMIT_WOUND 2
#define TRAUMA_LIMIT_LOBOTOMY 3
#define TRAUMA_LIMIT_MAGIC 3
#define TRAUMA_LIMIT_ABSOLUTE INFINITY

#define BRAIN_DAMAGE_INTEGRITY_MULTIPLIER 0.5

//Surgery Defines
#define BIOWARE_GENERIC "generic"
#define BIOWARE_NERVES "nerves"
#define BIOWARE_CIRCULATION "circulation"
#define BIOWARE_LIGAMENTS "ligaments"

//Health hud screws for carbon mobs
#define SCREWYHUD_NONE 0
#define SCREWYHUD_CRIT 1
#define SCREWYHUD_DEAD 2
#define SCREWYHUD_HEALTHY 3

//Moods levels for humans
#define MOOD_LEVEL_HAPPY4 15
#define MOOD_LEVEL_HAPPY3 10
#define MOOD_LEVEL_HAPPY2 6
#define MOOD_LEVEL_HAPPY1 2
#define MOOD_LEVEL_NEUTRAL 0
#define MOOD_LEVEL_SAD1 -3
#define MOOD_LEVEL_SAD2 -12
#define MOOD_LEVEL_SAD3 -18
#define MOOD_LEVEL_SAD4 -25

// Mob Caps
#define MAX_WALKINGMUSHROOM 50

//Sanity levels for humans
#define SANITY_GREAT 125
#define SANITY_NEUTRAL 100
#define SANITY_DISTURBED 75
#define SANITY_UNSTABLE 50
#define SANITY_CRAZY 25
#define SANITY_INSANE 0

//Nutrition levels for humans
#define NUTRITION_LEVEL_FAT 600
#define NUTRITION_LEVEL_FULL 550
#define NUTRITION_LEVEL_WELL_FED 450
#define NUTRITION_LEVEL_FED 350
#define NUTRITION_LEVEL_HUNGRY 250
#define NUTRITION_LEVEL_STARVING 150

#define NUTRITION_LEVEL_START_MIN 250
#define NUTRITION_LEVEL_START_MAX 400

//Disgust levels for humans
#define DISGUST_LEVEL_MAXEDOUT 150
#define DISGUST_LEVEL_DISGUSTED 75
#define DISGUST_LEVEL_VERYGROSS 50
#define DISGUST_LEVEL_GROSS 25

//Used as an upper limit for species that continuously gain nutriment
#define NUTRITION_LEVEL_ALMOST_FULL 535

//Charge levels for Ethereals
#define ETHEREAL_CHARGE_NONE 0
#define ETHEREAL_CHARGE_LOWPOWER 20
#define ETHEREAL_CHARGE_NORMAL 50
#define ETHEREAL_CHARGE_ALMOSTFULL 75
#define ETHEREAL_CHARGE_FULL 100

//Slime evolution threshold. Controls how fast slimes can split/grow
#define SLIME_EVOLUTION_THRESHOLD 10

//Slime extract crossing. Controls how many extracts is required to feed to a slime to core-cross.
#define SLIME_EXTRACT_CROSSING_REQUIRED 10

//Slime commands defines
#define SLIME_FRIENDSHIP_FOLLOW 			3 //Min friendship to order it to follow
#define SLIME_FRIENDSHIP_STOPEAT 			5 //Min friendship to order it to stop eating someone
#define SLIME_FRIENDSHIP_STOPEAT_NOANGRY	7 //Min friendship to order it to stop eating someone without it losing friendship
#define SLIME_FRIENDSHIP_STOPCHASE			4 //Min friendship to order it to stop chasing someone (their target)
#define SLIME_FRIENDSHIP_STOPCHASE_NOANGRY	6 //Min friendship to order it to stop chasing someone (their target) without it losing friendship
#define SLIME_FRIENDSHIP_STAY				3 //Min friendship to order it to stay
#define SLIME_FRIENDSHIP_ATTACK				8 //Min friendship to order it to attack

//Sentience types, to prevent things like sentience potions from giving bosses sentience
#define SENTIENCE_ORGANIC 1
#define SENTIENCE_ARTIFICIAL 2
// #define SENTIENCE_OTHER 3 unused
#define SENTIENCE_MINEBOT 4
#define SENTIENCE_BOSS 5

//Mob AI Status

//Hostile simple animals
//If you add a new status, be sure to add a list for it to the simple_animals global in _globalvars/lists/mobs.dm
#define AI_ON		1
#define AI_IDLE		2
#define AI_OFF		3
#define AI_Z_OFF	4

//determines if a mob can smash through it
#define ENVIRONMENT_SMASH_NONE			0
#define ENVIRONMENT_SMASH_STRUCTURES	(1<<0) 	//crates, lockers, ect
#define ENVIRONMENT_SMASH_WALLS			(1<<1)  //walls
#define ENVIRONMENT_SMASH_RWALLS		(1<<2)	//rwalls

#define NO_SLIP_WHEN_WALKING	(1<<0)
#define SLIDE					(1<<1)
#define GALOSHES_DONT_HELP		(1<<2)
#define SLIDE_ICE				(1<<3)
#define SLIP_WHEN_CRAWLING		(1<<4) //clown planet ruin

#define MAX_CHICKENS 50


#define INCORPOREAL_MOVE_BASIC 1
#define INCORPOREAL_MOVE_SHADOW 2 // leaves a trail of shadows
#define INCORPOREAL_MOVE_JAUNT 3 // is blocked by holy water/salt

//Secbot and ED209 judgement criteria bitflag values
#define JUDGE_EMAGGED		(1<<0)
#define JUDGE_IDCHECK		(1<<1)
#define JUDGE_WEAPONCHECK	(1<<2)
#define JUDGE_RECORDCHECK	(1<<3)
//ED209's ignore monkeys
#define JUDGE_IGNOREMONKEYS	(1<<4)

#define MEGAFAUNA_DEFAULT_RECOVERY_TIME 5

#define SHADOW_SPECIES_LIGHT_THRESHOLD 0.2

// Clothing type defines

#define CLOTHING_GENERIC "generic"
#define CLOTHING_UNIFORM "uniform"
#define CLOTHING_GLOVES "gloves"
#define CLOTHING_GLASSES "glasses"
#define CLOTHING_EARS "ears"
#define CLOTHING_SHOES "shoes"
#define CLOTHING_HEAD "head"
#define CLOTHING_BELT "belt"
#define CLOTHING_SUIT "suit"
#define CLOTHING_FACEMASK "mask"
#define CLOTHING_BACK "back"
#define CLOTHING_NECK "neck"

#define DEFAULTFILE_CLOTHING_EFFECTS 'icons/effects/clothing.dmi'
#define DEFAULTFILE_GENERIC 'icons/mob/mob.dmi'
#define DEFAULTFILE_UNIFORM 'icons/mob/clothing/default/uniform.dmi'
#define DEFAULTFILE_GLOVES 'icons/mob/clothing/default/hands.dmi'
#define DEFAULTFILE_GLASSES 'icons/mob/clothing/default/eyes.dmi'
#define DEFAULTFILE_EARS 'icons/mob/clothing/default/ears.dmi'
#define DEFAULTFILE_SHOES 'icons/mob/clothing/default/feet.dmi'
#define DEFAULTFILE_HEAD 'icons/mob/clothing/default/head.dmi'
#define DEFAULTFILE_BELT 'icons/mob/clothing/default/belt.dmi'
#define DEFAULTFILE_BELT_MIRROR 'icons/mob/clothing/default/belt_mirror.dmi'
#define DEFAULTFILE_SUIT 'icons/mob/clothing/default/suit.dmi'
#define DEFAULTFILE_FACEMASK 'icons/mob/clothing/default/mask.dmi'
#define DEFAULTFILE_BACK 'icons/mob/clothing/default/back.dmi'
#define DEFAULTFILE_NECK 'icons/mob/clothing/default/neck.dmi'
#define DEFAULTFILE_UNDERWEAR 'icons/mob/clothing/default/underwear.dmi'
#define DEFAULTFILE_ACCESSORIES 'icons/mob/clothing/default/accessories.dmi'

GLOBAL_LIST_INIT(clothing_default_files, list(
	"effects" = DEFAULTFILE_CLOTHING_EFFECTS,
	"underwear" = DEFAULTFILE_UNDERWEAR,
	"accessories" = DEFAULTFILE_ACCESSORIES,
	CLOTHING_GENERIC = DEFAULTFILE_GENERIC,
	CLOTHING_UNIFORM = DEFAULTFILE_UNIFORM,
	CLOTHING_GLOVES = DEFAULTFILE_GLOVES,
	CLOTHING_GLASSES = DEFAULTFILE_GLASSES,
	CLOTHING_EARS = DEFAULTFILE_EARS,
	CLOTHING_SHOES = DEFAULTFILE_SHOES,
	CLOTHING_HEAD = DEFAULTFILE_HEAD,
	CLOTHING_BELT = DEFAULTFILE_BELT,
	CLOTHING_SUIT = DEFAULTFILE_SUIT,
	CLOTHING_FACEMASK = DEFAULTFILE_FACEMASK,
	CLOTHING_BACK = DEFAULTFILE_BACK,
	CLOTHING_NECK = DEFAULTFILE_NECK,
	))

// Offsets defines

#define OFFSET_UNIFORM "uniform"
#define OFFSET_ID "id"
#define OFFSET_GLOVES "gloves"
#define OFFSET_GLASSES "glasses"
#define OFFSET_EARS "ears"
#define OFFSET_SHOES "shoes"
#define OFFSET_S_STORE "s_store"
#define OFFSET_FACEMASK "mask"
#define OFFSET_HEAD "head"
#define OFFSET_FACE "face"
#define OFFSET_BELT "belt"
#define OFFSET_BACK "back"
#define OFFSET_SUIT "suit"
#define OFFSET_NECK "neck"
#define OFFSET_LEFT_HAND "l_hand"
#define OFFSET_RIGHT_HAND "r_hand"

//MINOR TWEAKS/MISC
#define AGE_MIN				18	//youngest a character can be
#define AGE_MAX				85	//oldest a character can be
#define AGE_MINOR			21  //legal age of space drinking and smoking
#define WIZARD_AGE_MIN		30	//youngest a wizard can be
#define APPRENTICE_AGE_MIN	29	//youngest an apprentice can be
#define SHOES_SLOWDOWN		0	//How much shoes slow you down by default. Negative values speed you up
#define POCKET_STRIP_DELAY			40	//time taken (in deciseconds) to search somebody's pockets
#define DOOR_CRUSH_DAMAGE	15	//the amount of damage that airlocks deal when they crush you

#define	HUNGER_FACTOR		0.1	//factor at which mob nutrition decreases
#define	ETHEREAL_CHARGE_FACTOR	0.12 //factor at which ethereal's charge decreases
#define	REAGENTS_METABOLISM 0.4	//How many units of reagent are consumed per tick, by default.
#define REAGENTS_EFFECT_MULTIPLIER (REAGENTS_METABOLISM / 0.4)	// By defining the effect multiplier this way, it'll exactly adjust all effects according to how they originally were with the 0.4 metabolism

// Roundstart trait system

#define MAX_QUIRKS 6 //The maximum amount of quirks one character can have at roundstart

// AI Toggles
#define AI_CAMERA_LUMINOSITY	5
#define AI_VOX // Comment out if you don't want VOX to be enabled and have players download the voice sounds.

// /obj/item/bodypart on_mob_life() retval flag
#define BODYPART_LIFE_UPDATE_HEALTH (1<<0)

#define MAX_REVIVE_FIRE_DAMAGE 180
#define MAX_REVIVE_BRUTE_DAMAGE 180

#define HUMAN_FIRE_STACK_ICON_NUM	3

#define GRAB_PIXEL_SHIFT_PASSIVE 6
#define GRAB_PIXEL_SHIFT_AGGRESSIVE 12
#define GRAB_PIXEL_SHIFT_NECK 16

#define PULL_PRONE_SLOWDOWN 1.5
#define HUMAN_CARRY_SLOWDOWN 0.35

//Flags that control what things can spawn species (whitelist)
//Badmin magic mirror
#define MIRROR_BADMIN (1<<0)
//Standard magic mirror (wizard)
#define MIRROR_MAGIC  (1<<1)
//Pride ruin mirror
#define MIRROR_PRIDE  (1<<2)
//Race swap wizard event
#define RACE_SWAP     (1<<3)
//ERT spawn template (avoid races that don't function without correct gear)
#define ERT_SPAWN     (1<<4)
//xenobio black crossbreed
#define SLIME_EXTRACT (1<<5)
//Wabbacjack staff projectiles
#define WABBAJACK     (1<<6)

#define SLEEP_CHECK_DEATH(X) sleep(X); if(QDELETED(src) || stat == DEAD) return;
/// If you examine the same atom twice in this timeframe, we call examine_more() instead of examine()
#define EXAMINE_MORE_TIME	1 SECONDS
#define INTERACTING_WITH(X, Y) (Y in X.do_afters)


#define DOING_INTERACTION(user, interaction_key) (LAZYACCESS(user.do_afters, interaction_key))
